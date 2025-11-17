import Foundation
import CoreBluetooth
import UIKit

/// Manages Bluetooth LE connection and heart rate data parsing
@MainActor
class BluetoothManager: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var bluetoothState: BluetoothState = .unknown
    @Published var currentHeartRate: Double = 0
    @Published var lastUpdate: Date?
    @Published var lastError: Error?
    @Published var connectionTime: Date?

    // MARK: - Private Properties

    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var scanTimer: Timer?
    private var staleCheckTimer: Timer?

    // MARK: - Computed Properties

    var isConnected: Bool {
        bluetoothState.isConnected
    }

    var isStale: Bool {
        guard isConnected else { return false }
        guard let lastUpdate = lastUpdate else { return true }
        return Date().timeIntervalSince(lastUpdate) > 5
    }

    var hasGracePeriodExpired: Bool {
        guard let connectionTime = connectionTime else { return true }
        return Date().timeIntervalSince(connectionTime) > 5
    }

    // MARK: - Initialization

    override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [CBCentralManagerOptionRestoreIdentifierKey: "HeartRateMonitorCentral"]
        )
        startStaleCheckTimer()

        // Observe app lifecycle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        centralManager?.delegate = nil
        scanTimer?.invalidate()
        staleCheckTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    func startMonitoring() {
        guard let central = centralManager else { return }

        switch central.state {
        case .poweredOn:
            startScanning()
        case .poweredOff:
            bluetoothState = .poweredOff
        case .unauthorized:
            bluetoothState = .unauthorized
        case .unsupported:
            bluetoothState = .unsupported
        default:
            bluetoothState = .unknown
        }
    }

    func stopMonitoring() {
        scanTimer?.invalidate()
        centralManager?.stopScan()
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }

    func refreshConnection() {
        stopMonitoring()

        // Reset state
        currentHeartRate = 0
        lastUpdate = nil
        connectionTime = nil
        lastError = nil

        // Start fresh connection after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startMonitoring()
        }
    }

    // MARK: - Private Methods

    private func startScanning() {
        guard bluetoothState.canScan else { return }

        bluetoothState = .scanning
        centralManager?.scanForPeripherals(withServices: [Constants.heartRateServiceUUID], options: nil)

        // Start connection timeout
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: Constants.connectionTimeout, repeats: false) { [weak self] _ in
            self?.handleScanTimeout()
        }
    }

    private func handleScanTimeout() {
        if case .scanning = bluetoothState {
            centralManager?.stopScan()
            bluetoothState = .disconnected(nil)
            lastError = NSError(domain: "BluetoothManager", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "No heart rate monitor found. Please ensure your device is powered on and nearby."
            ])
        }
    }

    // MARK: - Stale Detection

    private func startStaleCheckTimer() {
        staleCheckTimer?.invalidate()
        staleCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    @objc private func appDidEnterBackground() {
        staleCheckTimer?.invalidate()
        staleCheckTimer = nil
    }

    @objc private func appWillEnterForeground() {
        startStaleCheckTimer()
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothState = .disconnected(nil)
            startMonitoring()
        case .poweredOff:
            bluetoothState = .poweredOff
        case .unauthorized:
            bluetoothState = .unauthorized
        case .unsupported:
            bluetoothState = .unsupported
        default:
            bluetoothState = .unknown
        }
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                peripheral.delegate = self
                connectedPeripheral = peripheral
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        scanTimer?.invalidate()
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        central.stopScan()
        bluetoothState = .connecting(peripheral)
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        bluetoothState = .connected(peripheral)
        connectionTime = Date()
        peripheral.discoverServices([Constants.heartRateServiceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        bluetoothState = .disconnected(error)
        currentHeartRate = 0
        lastUpdate = nil
        connectionTime = nil
        lastError = error

        // Auto-reconnect after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.startMonitoring()
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        bluetoothState = .disconnected(error)
        lastError = error
        startMonitoring()
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            lastError = error
            return
        }

        guard let services = peripheral.services else {
            lastError = NSError(domain: "BluetoothManager", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "No services found on device"
            ])
            return
        }

        for service in services {
            if service.uuid == Constants.heartRateServiceUUID {
                peripheral.discoverCharacteristics([Constants.heartRateMeasurementUUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            lastError = error
            return
        }

        guard let characteristics = service.characteristics else {
            lastError = NSError(domain: "BluetoothManager", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "No characteristics found for heart rate service"
            ])
            return
        }

        for characteristic in characteristics {
            if characteristic.uuid == Constants.heartRateMeasurementUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            lastError = error
            return
        }

        if characteristic.uuid == Constants.heartRateMeasurementUUID {
            guard let data = characteristic.value else { return }

            let bytes = [UInt8](data)
            if bytes.isEmpty { return }

            let flags = bytes[0]
            let is16Bit = (flags & 0x01) != 0

            var bpm: UInt16 = 0
            if is16Bit && bytes.count >= 3 {
                bpm = UInt16(bytes[1]) | (UInt16(bytes[2]) << 8)
            } else if bytes.count >= 2 {
                bpm = UInt16(bytes[1])
            }

            DispatchQueue.main.async {
                self.currentHeartRate = Double(bpm)
                self.lastUpdate = Date()
            }
        }
    }
}

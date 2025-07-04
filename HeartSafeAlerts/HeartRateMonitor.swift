import Foundation
import CoreBluetooth
import UserNotifications
import AVFoundation
import UIKit

class HeartRateMonitor: NSObject, ObservableObject {
    @Published var bluetoothState: BluetoothState = .unknown
    @Published var currentHeartRate: Double = 0
    @Published var lastUpdate: Date?
    @Published var lastError: Error?
    @Published var isStale: Bool = false
    @Published var connectionTime: Date?  // Added for grace period
    
    @Published var minHeartRate: Int = Constants.defaultMinHeartRate {
        didSet {
            UserDefaults.standard.set(minHeartRate, forKey: Constants.minHeartRateKey)
        }
    }
    
    @Published var maxHeartRate: Int = Constants.defaultMaxHeartRate {
        didSet {
            UserDefaults.standard.set(maxHeartRate, forKey: Constants.maxHeartRateKey)
        }
    }
    
    // UPDATED: Default to OFF for better privacy/premium positioning
    @Published var soundAlertsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(soundAlertsEnabled, forKey: Constants.soundAlertsEnabledKey)
        }
    }
    
    @Published var vibrationAlertsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(vibrationAlertsEnabled, forKey: Constants.vibrationAlertsEnabledKey)
        }
    }
    
    // UPDATED: Default to OFF
    @Published var alertsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(alertsEnabled, forKey: Constants.alertsEnabledKey)
        }
    }
    
    private var lastNotificationTime: Date?
    private var lastAlertTime: Date?
    private var scanTimer: Timer?
    private var staleCheckTimer: Timer?
    
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        loadPreferences()
        // Add state restoration support
        centralManager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [CBCentralManagerOptionRestoreIdentifierKey: "HeartRateMonitorCentral"]
        )
        setupAudioSession()
        startStaleCheckTimer()
        
        // Observe app lifecycle for timer management
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
    
    private func loadPreferences() {
        minHeartRate = UserDefaults.standard.object(forKey: Constants.minHeartRateKey) as? Int ?? Constants.defaultMinHeartRate
        maxHeartRate = UserDefaults.standard.object(forKey: Constants.maxHeartRateKey) as? Int ?? Constants.defaultMaxHeartRate
        
        // UPDATED: Default to false (OFF) for new users
        alertsEnabled = UserDefaults.standard.object(forKey: Constants.alertsEnabledKey) as? Bool ?? false
        soundAlertsEnabled = UserDefaults.standard.object(forKey: Constants.soundAlertsEnabledKey) as? Bool ?? false
        vibrationAlertsEnabled = UserDefaults.standard.object(forKey: Constants.vibrationAlertsEnabledKey) as? Bool ?? false
        
        // UPDATED: Default background notifications to OFF
        if UserDefaults.standard.object(forKey: Constants.backgroundNotificationsEnabledKey) == nil {
            UserDefaults.standard.set(false, forKey: Constants.backgroundNotificationsEnabledKey)
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            lastError = error
        }
    }
    
    // MARK: - Manual Refresh Connection
    func refreshConnection() {
        // Stop any current operations
        stopMonitoring()
        
        // Reset state
        currentHeartRate = 0
        lastUpdate = nil
        connectionTime = nil
        isStale = false
        
        // Clear any previous errors
        lastError = nil
        
        // Start fresh connection attempt after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startMonitoring()
        }
    }
    
    // MARK: - Stale Detection
    
    private func startStaleCheckTimer() {
        staleCheckTimer?.invalidate()
        staleCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateStaleStatus()
        }
    }
    
    private func updateStaleStatus() {
        guard isConnected else {
            isStale = false
            return
        }
        
        if let lastUpdate = lastUpdate {
            isStale = Date().timeIntervalSince(lastUpdate) > 5
        } else {
            isStale = true
        }
    }
    
    @objc private func appDidEnterBackground() {
        // Pause timer when backgrounded to save battery
        staleCheckTimer?.invalidate()
        staleCheckTimer = nil
    }
    
    @objc private func appWillEnterForeground() {
        // Resume timer when foregrounded
        startStaleCheckTimer()
        updateStaleStatus()  // Update immediately
    }
    
    var isConnected: Bool {
        bluetoothState.isConnected
    }
    
    var hasGracePeriodExpired: Bool {
        guard let connectionTime = connectionTime else { return true }
        return Date().timeIntervalSince(connectionTime) > 5
    }
    
    var isOutOfRange: Bool {
        guard isConnected else { return false }
        guard !isStale else { return false }  // Don't alert on stale data
        guard hasGracePeriodExpired else { return false }  // Grace period check
        return currentHeartRate < Double(minHeartRate) || currentHeartRate > Double(maxHeartRate)
    }
    
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
    
    private func startScanning() {
        guard bluetoothState.canScan else { return }
        
        bluetoothState = .scanning
        centralManager?.scanForPeripherals(withServices: [Constants.heartRateServiceUUID], options: nil)
        
        // Start connection timeout timer
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: Constants.connectionTimeout, repeats: false) { [weak self] _ in
            self?.handleScanTimeout()
        }
    }
    
    private func handleScanTimeout() {
        if case .scanning = bluetoothState {
            centralManager?.stopScan()
            bluetoothState = .disconnected(nil)
            lastError = NSError(domain: "HeartRateMonitor", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "No heart rate monitor found. Please ensure your device is powered on and nearby."
            ])
        }
    }
    
    func stopMonitoring() {
        scanTimer?.invalidate()
        centralManager?.stopScan()
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: - Alert Methods
    
    private func checkHeartRateAndAlert() {
        // Check if user has premium before any alerts
        guard UserDefaults.standard.bool(forKey: "isPremium") else { return }
        guard alertsEnabled else { return }
        guard isOutOfRange else { return }
        
        if let lastTime = lastAlertTime,
           Date().timeIntervalSince(lastTime) < Constants.defaultAlertCooldown {
            return
        }
        
        // Separate sound and vibration controls
        if soundAlertsEnabled {
            AudioServicesPlaySystemSound(Constants.alertSoundID)
        }
        
        if vibrationAlertsEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }
        
        lastAlertTime = Date()
    }
    
    private func checkHeartRateAndNotify() {
        // Check if user has premium before any notifications
        guard UserDefaults.standard.bool(forKey: "isPremium") else { return }
        guard alertsEnabled else { return }
        guard UserDefaults.standard.bool(forKey: Constants.backgroundNotificationsEnabledKey) else { return }
        guard isOutOfRange else { return }
        
        if let lastTime = lastNotificationTime,
           Date().timeIntervalSince(lastTime) < Constants.defaultNotificationCooldown {
            return
        }
        
        sendNotification()
        lastNotificationTime = Date()
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Heart Rate Alert!"
        
        if currentHeartRate < Double(minHeartRate) {
            content.body = "Your heart rate is too low: \(Int(currentHeartRate)) BPM (minimum: \(minHeartRate) BPM)"
        } else {
            content.body = "Your heart rate is too high: \(Int(currentHeartRate)) BPM (maximum: \(maxHeartRate) BPM)"
        }
        
        content.sound = .default
        content.categoryIdentifier = Constants.notificationCategoryIdentifier
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                self?.lastError = error
            }
        }
    }
    
    deinit {
        centralManager?.delegate = nil
        scanTimer?.invalidate()
        staleCheckTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - CBCentralManagerDelegate

extension HeartRateMonitor: CBCentralManagerDelegate {
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
    
    // State restoration method
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
        connectionTime = Date()  // Start grace period
        isStale = true  // Start as stale until we get data
        peripheral.discoverServices([Constants.heartRateServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        bluetoothState = .disconnected(error)
        currentHeartRate = 0
        lastUpdate = nil
        connectionTime = nil  // Clear grace period
        isStale = false
        lastError = error
        
        // Auto-reconnect after a short delay
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

extension HeartRateMonitor: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            lastError = error
            return
        }
        
        guard let services = peripheral.services else {
            lastError = NSError(domain: "HeartRateMonitor", code: 2, userInfo: [
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
            lastError = NSError(domain: "HeartRateMonitor", code: 3, userInfo: [
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
                self.isStale = false  // We just got fresh data
                self.checkHeartRateAndAlert()
                self.checkHeartRateAndNotify()
            }
        }
    }
}

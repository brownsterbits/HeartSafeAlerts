import Foundation
import CoreBluetooth

enum BluetoothState: Equatable {
    case unknown
    case poweredOff
    case unauthorized
    case unsupported
    case scanning
    case connecting(CBPeripheral)
    case connected(CBPeripheral)
    case disconnected(Error?)
    
    var description: String {
        switch self {
        case .unknown:
            return "Initializing..."
        case .poweredOff:
            return "Bluetooth is turned off"
        case .unauthorized:
            return "Bluetooth permission denied"
        case .unsupported:
            return "Bluetooth not supported"
        case .scanning:
            return "Searching for heart rate monitor..."
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .disconnected(let error):
            if error != nil {
                return "Connection lost"
            }
            return "Disconnected"
        }
    }
    
    var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }
    
    var canScan: Bool {
        switch self {
        case .disconnected, .scanning:
            return true
        default:
            return false
        }
    }
    
    // Implement Equatable
    static func == (lhs: BluetoothState, rhs: BluetoothState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown),
             (.poweredOff, .poweredOff),
             (.unauthorized, .unauthorized),
             (.unsupported, .unsupported),
             (.scanning, .scanning):
            return true
        case (.connecting(let lhsPeripheral), .connecting(let rhsPeripheral)),
             (.connected(let lhsPeripheral), .connected(let rhsPeripheral)):
            return lhsPeripheral.identifier == rhsPeripheral.identifier
        case (.disconnected(let lhsError), .disconnected(let rhsError)):
            return (lhsError as NSError?)?.code == (rhsError as NSError?)?.code
        default:
            return false
        }
    }
}
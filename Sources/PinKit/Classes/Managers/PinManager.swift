import Combine
import StorageKit

class PinManager {
    private let biometricOnKey = "biometric_on_key"
    private let pinKey = "pin_keychain_key"

    private let secureStorage: ISecureStorage
    private let localStorage: ILocalStorage

    private let isPinSetSubject = PassthroughSubject<Bool, Never>()

    init(secureStorage: ISecureStorage, localStorage: ILocalStorage) {
        self.secureStorage = secureStorage
        self.localStorage = localStorage
    }

}

extension PinManager {

    var isPinSet: Bool {
        secureStorage.value(for: pinKey) != nil
    }

    var biometryEnabled: Bool {
        get {
            localStorage.value(for: biometricOnKey) ?? false
        }
        set {
            localStorage.set(value: newValue, for: biometricOnKey)
        }
    }

    func store(pin: String) throws {
        try secureStorage.set(value: pin, for: pinKey)
        isPinSetSubject.send(true)
    }

    func validate(pin: String) -> Bool {
        secureStorage.value(for: pinKey) == pin
    }

    func clear() throws {
        try secureStorage.removeValue(for: pinKey)
        localStorage.set(value: false, for: biometricOnKey)
        isPinSetSubject.send(false)
    }

    var isPinSetPublisher: AnyPublisher<Bool, Never> {
        isPinSetSubject.eraseToAnyPublisher()
    }

}

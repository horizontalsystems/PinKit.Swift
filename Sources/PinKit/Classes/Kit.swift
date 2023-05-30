import Combine
import UIKit
import LanguageKit
import StorageKit

public class Kit {
    private let secureStorage: ISecureStorage
    private let localStorage: ILocalStorage

    private let biometryManager: BiometryManager
    private let pinManager: PinManager
    private let lockManager: LockManager
    private let lockoutManager: LockoutManager

    public init(secureStorage: ISecureStorage, localStorage: ILocalStorage) {
        self.secureStorage = secureStorage
        self.localStorage = localStorage

        biometryManager = BiometryManager()
        pinManager = PinManager(secureStorage: secureStorage, localStorage: localStorage)
        lockManager = LockManager(pinManager: pinManager, localStorage: localStorage)

        let lockoutUntilDateFactory = LockoutUntilDateFactory()
        lockoutManager = LockoutManager(secureStorage: secureStorage, lockoutTimeFrameFactory: lockoutUntilDateFactory)
    }

}

extension Kit {

    public func set(delegate: IPinKitDelegate?) {
        lockManager.delegate = delegate
    }

    public var isPinSet: Bool {
        pinManager.isPinSet
    }

    public var isPinSetPublisher: AnyPublisher<Bool, Never> {
        pinManager.isPinSetPublisher
    }

    public var biometryType: BiometryType? {
        biometryManager.biometryType
    }

    public var biometryTypePublisher: AnyPublisher<BiometryType, Never> {
        biometryManager.biometryTypePublisher
    }

    public func clear() throws {
        try pinManager.clear()
    }

    public var biometryEnabled: Bool {
        get {
            pinManager.biometryEnabled
        }
        set {
            pinManager.biometryEnabled = newValue
        }
    }

    public var isLocked: Bool {
        lockManager.isLocked
    }

    public func lock() {
        lockManager.lock()
    }

    public func didFinishLaunching() {
        biometryManager.refresh()
    }

    public func didEnterBackground() {
        lockManager.didEnterBackground()
    }

    public func willEnterForeground() {
        lockManager.willEnterForeground()
        biometryManager.refresh()
    }

    public var editPinModule: UIViewController {
        EditPinRouter.module(pinManager: pinManager)
    }

    public func setPinModule(delegate: ISetPinDelegate) -> UIViewController {
        SetPinRouter.module(delegate: delegate, pinManager: pinManager)
    }

    public func unlockPinModule(biometryUnlockMode: BiometryUnlockMode, insets: UIEdgeInsets, cancellable: Bool, autoDismiss: Bool, onUnlock: (() -> ())? = nil, onCancelUnlock: (() -> ())? = nil) -> UIViewController {
        UnlockPinRouter.module(
                pinManager: pinManager,
                lockoutManager: lockoutManager,
                biometryManager: biometryManager,
                biometryUnlockMode: biometryUnlockMode,
                insets: insets,
                cancellable: cancellable,
                autoDismiss: autoDismiss,
                onUnlock: { [weak self] in
                    self?.lockManager.onUnlock()
                    onUnlock?()
                },
                onCancelUnlock: {
                    onCancelUnlock?()
                }
        )
    }

}

public protocol IPinKitDelegate: AnyObject {
    func onLock()
}

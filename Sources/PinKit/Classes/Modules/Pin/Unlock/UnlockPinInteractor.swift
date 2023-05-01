import Foundation
import Combine

class UnlockPinInteractor {
    weak var delegate: IUnlockPinInteractorDelegate?

    private let pinManager: PinManager
    private let biometricManager: BiometricManager
    private let lockoutManager: LockoutManager
    private var timer: OneTimeTimer
    private var biometryManager: BiometryManager

    private var cancellables = Set<AnyCancellable>()

    init(pinManager: PinManager, biometricManager: BiometricManager, lockoutManager: LockoutManager, timer: OneTimeTimer, biometryManager: BiometryManager) {
        self.pinManager = pinManager
        self.biometricManager = biometricManager
        self.lockoutManager = lockoutManager
        self.timer = timer
        self.biometryManager = biometryManager

        self.timer.delegate = self
    }

}

extension UnlockPinInteractor: IUnlockPinInteractor {

    var biometryEnabled: Bool {
        pinManager.biometryEnabled
    }

    var biometryType: BiometryType? {
        biometryManager.biometryType
    }

    var failedAttempts: Int {
        lockoutManager.unlockAttempts
    }

    func subscribeBiometryType() {
        biometryManager.biometryTypePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] biometryType in
                    self?.delegate?.didUpdate(biometryType: biometryType)
                }
                .store(in: &cancellables)
    }

    func updateLockoutState() {
        let state = lockoutManager.currentState
        delegate?.update(lockoutState: state)

        if case .locked(let till) = state {
            timer.schedule(date: till)
        }
    }

    func unlock(with pin: String) -> Bool {
        guard pinManager.validate(pin: pin) else {
            lockoutManager.didFailUnlock()

            updateLockoutState()

            return false
        }

        lockoutManager.dropFailedAttempts()
        return true
    }

    func biometricUnlock() {
        biometricManager.validate(reason: "biometric_usage_reason")//
    }

}

extension UnlockPinInteractor: IBiometricManagerDelegate {

    func didValidate() {
        delegate?.didBiometricUnlock()
    }

    func didFailToValidate() {
        delegate?.didFailBiometricUnlock()
    }

}

extension UnlockPinInteractor: IPeriodicTimerDelegate {

    func onFire() {
        updateLockoutState()
    }

}

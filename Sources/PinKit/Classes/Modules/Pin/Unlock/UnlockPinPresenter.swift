import Foundation

class UnlockPinPresenter {

    enum Page: Int { case unlock }

    weak var view: IPinView?
    private let interactor: IUnlockPinInteractor
    private let router: IUnlockPinRouter

    private let configuration: UnlockPresenterConfiguration

    init(interactor: IUnlockPinInteractor, router: IUnlockPinRouter, configuration: UnlockPresenterConfiguration = .init(cancellable: false, biometryUnlockMode: .auto)) {
        self.interactor = interactor
        self.router = router
        self.configuration = configuration
    }

    private func updateView(biometryType: BiometryType?) {
        view?.set(biometryUnlockMode: configuration.biometryUnlockMode, biometryType: biometryType, biometryEnabled: interactor.biometryEnabled)
    }

}

extension UnlockPinPresenter: IPinViewDelegate {

    func viewDidLoad() {
        view?.addPage(withDescription: "unlock_pin.info")

        interactor.subscribeBiometryType()

        updateView(biometryType: interactor.biometryType)

        if interactor.failedAttempts == 0, interactor.biometryEnabled, configuration.biometryUnlockMode == .auto {
            interactor.biometricUnlock()
        }

        if configuration.cancellable {
            view?.showCancel()
        }

        interactor.updateLockoutState()
    }

    func onEnter(pin: String, forPage index: Int) {
        if interactor.unlock(with: pin) {
            router.dismiss(didUnlock: true)
        } else {
            view?.showPinWrong(page: Page.unlock.rawValue)
        }
    }

    func onCancel() {
        router.dismiss(didUnlock: false)
    }

    func onTapBiometric() {
        interactor.biometricUnlock()
    }

}

extension UnlockPinPresenter: IUnlockPinInteractorDelegate {

    func didBiometricUnlock() {
        router.dismiss(didUnlock: true)
    }

    func didFailBiometricUnlock() {
    }

    func update(lockoutState: LockoutState) {
        switch lockoutState {
        case .unlocked(let attemptsLeft):
            view?.show(attemptsLeft: attemptsLeft, forPage: Page.unlock.rawValue)
        case .locked(let dueDate):
            view?.showLockView(till: dueDate)
        }
    }

    func didUpdate(biometryType: BiometryType) {
        updateView(biometryType: biometryType)
    }

}

import UIKit
import StorageKit

class UnlockPinRouter {
    weak var viewController: UIViewController?

    private let onUnlock: () -> ()
    private let onCancelUnlock: () -> ()
    private let autoDismiss: Bool

    init(onUnlock: @escaping () -> (), onCancelUnlock: @escaping () -> (), autoDismiss: Bool) {
        self.onUnlock = onUnlock
        self.onCancelUnlock = onCancelUnlock
        self.autoDismiss = autoDismiss
    }

}

extension UnlockPinRouter: IUnlockPinRouter {

    func dismiss(didUnlock: Bool) {
        if autoDismiss {
            viewController?.dismiss(animated: true)
        }

        if didUnlock {
            onUnlock()
        } else {
            onCancelUnlock()
        }
    }

}

extension UnlockPinRouter {

    static func module(pinManager: PinManager, lockoutManager: LockoutManager, biometryManager: BiometryManager, biometryUnlockMode: BiometryUnlockMode, insets: UIEdgeInsets, cancellable: Bool, autoDismiss: Bool, onUnlock: @escaping () -> (), onCancelUnlock: @escaping () -> ()) -> UIViewController {
        let biometricManager = BiometricManager()
        let timer = OneTimeTimer()

        let router = UnlockPinRouter(onUnlock: onUnlock, onCancelUnlock: onCancelUnlock, autoDismiss: autoDismiss)
        let interactor = UnlockPinInteractor(pinManager: pinManager, biometricManager: biometricManager, lockoutManager: lockoutManager, timer: timer, biometryManager: biometryManager)
        let presenter = UnlockPinPresenter(interactor: interactor, router: router, configuration: .init(cancellable: cancellable, biometryUnlockMode: biometryUnlockMode))

        let viewController = PinViewController(delegate: presenter, insets: insets)

        biometricManager.delegate = interactor
        interactor.delegate = presenter
        presenter.view = viewController
        router.viewController = viewController

        viewController.modalPresentationStyle = .fullScreen

        return viewController
    }

}

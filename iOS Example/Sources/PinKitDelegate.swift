import UIKit
import PinKit

class PinKitDelegate {
    var viewController: UIViewController?
}

extension PinKitDelegate: IPinKitDelegate {

    func onLock() {
        var controller = viewController

        while let presentedController = controller?.presentedViewController {
            controller = presentedController
        }

        controller?.present(App.shared.pinKit.unlockPinModule(biometryUnlockMode: .auto, insets: .zero, cancellable: false, autoDismiss: true), animated: true)
    }

}

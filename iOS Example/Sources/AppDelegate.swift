import UIKit
import PinKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .white

        if App.shared.pinKit.isPinSet {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: .margin12x, right: 0)
            window?.rootViewController = App.shared.pinKit.unlockPinModule(
                    biometryUnlockMode: .auto,
                    insets: insets,
                    cancellable: false,
                    autoDismiss: false,
                    onUnlock: {
                        UIApplication.shared.windows.first { $0.isKeyWindow }?.set(newRootController: PinController())
                    },
                    onCancelUnlock: {
                        print("On cancel unlock")
                    }
            )
        } else {
            window?.rootViewController = PinController()
        }

        App.shared.pinKit.didFinishLaunching()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        App.shared.pinKit.didEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        App.shared.pinKit.willEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}

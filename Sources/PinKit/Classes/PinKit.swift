import UIKit
import LanguageKit

class PinKit {

    static var bundle: Bundle? {
        Bundle.module
    }

    static func image(named: String) -> UIImage? {
        UIImage(named: named, in: Bundle.module, compatibleWith: nil)
    }

}

extension String {

    var localized: String {
        LanguageManager.shared.localize(string: self, bundle: PinKit.bundle)
    }

    func localized(_ arguments: CVarArg...) -> String {
        LanguageManager.shared.localize(string: self, bundle: PinKit.bundle, arguments: arguments)
    }

}

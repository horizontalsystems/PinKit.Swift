import Combine
import LocalAuthentication
import HsExtensions

class BiometryManager {
    private var tasks = Set<AnyTask>()

    private let subject = PassthroughSubject<BiometryType, Never>()

    var biometryType: BiometryType? {
        didSet {
            if let biometryType = biometryType, oldValue != biometryType {
                subject.send(biometryType)
            }
        }
    }

    var biometryTypePublisher: AnyPublisher<BiometryType, Never> {
        subject.eraseToAnyPublisher()
    }

    func refresh() {
        Task { [weak self] in
            var authError: NSError?
            let localAuthenticationContext = LAContext()
            let biometryType: BiometryType

            // Some times canEvaluatePolicy responses for too long time leading to stuck in settings controller.
            // Sending this request to background thread allows to show controller without biometric setting.
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                switch localAuthenticationContext.biometryType {
                case .faceID: biometryType = .faceId
                case .touchID: biometryType = .touchId
                default: biometryType = .none
                }
            } else {
                biometryType = .none
            }

            self?.biometryType = biometryType
        }.store(in: &tasks)
    }

}

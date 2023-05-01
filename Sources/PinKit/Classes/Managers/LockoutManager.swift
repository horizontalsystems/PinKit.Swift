import Foundation
import StorageKit

class LockoutManager {
    private let unlockAttemptsKey = "unlock_attempts_keychain_key"
    private let lockTimestampKey = "lock_timestamp_keychain_key"

    private var secureStorage: ISecureStorage
    private var lockoutTimeFrameFactory: LockoutUntilDateFactory

    private let lockoutThreshold = 5

    init(secureStorage: ISecureStorage, lockoutTimeFrameFactory: LockoutUntilDateFactory) {
        self.secureStorage = secureStorage
        self.lockoutTimeFrameFactory = lockoutTimeFrameFactory
    }

    private var uptime: TimeInterval {
        var uptime = timespec()
        clock_gettime(CLOCK_MONOTONIC_RAW, &uptime)
        return TimeInterval(uptime.tv_sec)
    }

}

extension LockoutManager {

    var unlockAttempts: Int {
        secureStorage.value(for: unlockAttemptsKey) ?? 0
    }

    var currentState: LockoutState {
        let uptime = uptime
        let lockoutTimestamp = secureStorage.value(for: lockTimestampKey) ?? uptime

        let unlockAttempts: Int = secureStorage.value(for: unlockAttemptsKey) ?? 0
        let unlockDate = lockoutTimeFrameFactory.lockoutUntilDate(failedAttempts: unlockAttempts, lockoutTimestamp: lockoutTimestamp, uptime: uptime)

        if unlockAttempts >= lockoutThreshold, Date().compare(unlockDate) == .orderedAscending {
            return .locked(till: unlockDate)
        } else {
            let failedAttempts: Int? = secureStorage.value(for: unlockAttemptsKey)
            let attemptsLeft = failedAttempts.map { failedAttempts -> Int in
                let attemptsLeft = lockoutThreshold - failedAttempts
                return attemptsLeft < 1 ? 1 : attemptsLeft
            }
            return .unlocked(attemptsLeft: attemptsLeft)
        }
    }

    func didFailUnlock() {
        let newValue = (secureStorage.value(for: unlockAttemptsKey) ?? 0) + 1
        try? secureStorage.set(value: newValue, for: unlockAttemptsKey)

        if newValue >= lockoutThreshold {
            try? secureStorage.set(value: uptime, for: lockTimestampKey)
        }
    }

    func dropFailedAttempts() {
        try? secureStorage.removeValue(for: unlockAttemptsKey)
    }

}

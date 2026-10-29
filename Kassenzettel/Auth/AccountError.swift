import Foundation

enum AccountError: LocalizedError {
    case notSignedIn
    case wrongCurrentPassword

    var errorDescription: String? {
        switch self {
        case .notSignedIn: "Nicht angemeldet. Bitte melde dich erneut an."
        case .wrongCurrentPassword: "Das aktuelle Passwort ist falsch."
        }
    }
}

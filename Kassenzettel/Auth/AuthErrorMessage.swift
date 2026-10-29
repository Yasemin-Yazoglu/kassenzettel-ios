import Auth
import Foundation

enum AuthErrorMessage {
    static func text(for error: Error) -> String {
        if let accountError = error as? AccountError, let message = accountError.errorDescription {
            return message
        }
        if let authError = error as? AuthError {
            switch authError.errorCode.rawValue {
            case "invalid_credentials":
                return "E-Mail oder Passwort ist falsch."
            case "email_not_confirmed":
                return "Bitte bestätige zuerst deine E-Mail-Adresse."
            case "user_already_exists", "email_exists":
                return "Mit dieser E-Mail gibt es schon ein Konto."
            case "weak_password":
                return "Das Passwort ist zu schwach."
            case "same_password":
                return "Das neue Passwort muss sich vom aktuellen unterscheiden."
            case "over_email_send_rate_limit", "over_request_rate_limit":
                return "Zu viele Versuche. Bitte warte einen Moment."
            default:
                break
            }
        }
        return "Etwas ist schiefgelaufen. Bitte versuche es erneut."
    }
}

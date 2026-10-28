import Foundation

enum AuthValidation {
    static func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func isValidEmail(_ email: String) -> Bool {
        email.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil
    }

    /// Gleiche Regeln wie die Web-App. Gibt eine Fehlermeldung zurück oder nil, wenn alles passt.
    static func passwordProblem(_ password: String) -> String? {
        if password.count < 8 { return "Das Passwort muss mindestens 8 Zeichen lang sein." }
        if password.count > 72 { return "Das Passwort darf höchstens 72 Zeichen lang sein." }
        if password.range(of: "[A-Z]", options: .regularExpression) == nil {
            return "Das Passwort braucht mindestens einen Großbuchstaben."
        }
        if password.range(of: "[a-z]", options: .regularExpression) == nil {
            return "Das Passwort braucht mindestens einen Kleinbuchstaben."
        }
        return nil
    }
}

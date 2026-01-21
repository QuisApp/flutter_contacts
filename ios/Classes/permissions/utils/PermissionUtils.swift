import Contacts

enum PermissionUtils {
    static func mapAuthorizationStatus(_ status: CNAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "granted"
        case .denied: return "permanentlyDenied"
        case .limited: return "limited"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        @unknown default: return "notDetermined"
        }
    }
}

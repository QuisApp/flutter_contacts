import Contacts

enum PermissionUtils {
    static func mapAuthorizationStatus(_ status: CNAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "granted"
        case .denied: return "permanentlyDenied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .limited: return "limited"
        @unknown default: return "notDetermined"
        }
    }
}

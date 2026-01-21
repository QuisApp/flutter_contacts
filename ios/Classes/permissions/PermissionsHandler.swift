import Flutter

final class PermissionsHandler: MethodRouter {
    init() {
        super.init([
            "check": CheckPermissionImpl.handle,
            "request": RequestPermissionImpl.handle,
            "openSettings": OpenSettingsImpl.handle,
        ])
    }
}

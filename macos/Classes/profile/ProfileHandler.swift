import FlutterMacOS

final class ProfileHandler: MethodRouter {
    init() {
        super.init([
            "get": GetMeImpl.handle,
        ])
    }
}

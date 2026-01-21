import FlutterMacOS

final class CrudHandler: MethodRouter {
    init() {
        super.init([
            "get": GetImpl.handle,
            "getAll": GetAllImpl.handle,
            "create": CreateImpl.handle,
            "createAll": CreateAllImpl.handle,
            "update": UpdateImpl.handle,
            "updateAll": UpdateAllImpl.handle,
            "delete": DeleteImpl.handle,
            "deleteAll": DeleteAllImpl.handle,
        ])
    }
}

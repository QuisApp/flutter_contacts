import FlutterMacOS

final class AccountsHandler: MethodRouter {
    init() {
        super.init([
            "getAll": GetAllAccountsImpl.handle,
            "getDefault": GetDefaultImpl.handle,
            "showDefaultPicker": ShowDefaultPickerImpl.handle,
        ])
    }
}

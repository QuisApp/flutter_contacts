import Flutter

final class NativeHandler: MethodRouter {
    init() {
        super.init([
            "showViewer": ShowViewerImpl.handle,
            "showPicker": ShowPickerImpl.handle,
            "showEditor": ShowEditorImpl.handle,
            "showCreator": ShowCreatorImpl.handle,
        ])
    }
}

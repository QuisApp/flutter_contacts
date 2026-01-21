import Flutter
import Foundation

extension FlutterMethodCall {
    func arg<T>(_ key: String) -> T? {
        args?[key] as? T
    }

    func arg<T>(_ key: String, default defaultValue: T) -> T {
        args?[key] as? T ?? defaultValue
    }

    func argList<T>(_ key: String) -> [T]? {
        (args?[key] as? [Any])?.compactMap { $0 as? T }
    }

    var args: Json? {
        arguments as? Json
    }
}

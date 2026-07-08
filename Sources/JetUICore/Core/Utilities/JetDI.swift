//
//  JetDI.swift
//  JetUI
//
//  Lightweight dependency registry for host app services.
//

import Foundation

public enum JetDependencyScope {
    case app
    case transient
}

@MainActor
public enum JetDI {
    private final class FactoryBox {
        let scope: JetDependencyScope
        let factory: () -> Any
        lazy var instance: Any = factory()

        init(scope: JetDependencyScope, factory: @escaping () -> Any) {
            self.scope = scope
            self.factory = factory
        }
    }

    private static var container: [ObjectIdentifier: FactoryBox] = [:]

    public static func register<T>(
        _ type: T.Type = T.self,
        scope: JetDependencyScope = .app,
        factory: @escaping () -> T
    ) {
        container[ObjectIdentifier(type)] = FactoryBox(scope: scope, factory: factory)
    }

    public static func resolve<T>(_ type: T.Type = T.self) -> T {
        let key = ObjectIdentifier(type)
        guard let box = container[key] else {
            fatalError("JetDI: no registration for \(T.self)")
        }

        switch box.scope {
        case .app:
            guard let value = box.instance as? T else {
                fatalError("JetDI: registered instance for \(T.self) has unexpected type")
            }
            return value
        case .transient:
            guard let value = box.factory() as? T else {
                fatalError("JetDI: registered factory for \(T.self) returned unexpected type")
            }
            return value
        }
    }

    public static func reset() {
        container.removeAll()
    }
}

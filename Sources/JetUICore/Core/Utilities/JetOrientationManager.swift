//
//  JetOrientationManager.swift
//  JetUI
//
//  Shared iOS orientation lock helper.
//

import SwiftUI
import UIKit

@MainActor
public final class JetOrientationManager: ObservableObject {
    public static let shared = JetOrientationManager()

    @Published public private(set) var lockedOrientation: UIInterfaceOrientationMask

    public init(initialOrientation: UIInterfaceOrientationMask = .portrait) {
        self.lockedOrientation = initialOrientation
    }

    public func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        lockedOrientation = orientation
        updateOrientation()
    }

    private func updateOrientation() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: lockedOrientation))
        }
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

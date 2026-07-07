//
//  JetTextFieldAlert.swift
//  JetUI
//
//  Text field alert extension for SwiftUI
//

import SwiftUI

// MARK: - View Extension for Text Field Alert

public extension View {
    
    /// Show an alert with a text field for user input
    /// - Parameters:
    ///   - isPresented: Binding to control alert visibility
    ///   - title: Alert title
    ///   - message: Optional alert message
    ///   - text: Binding to the text field value
    ///   - placeholder: Text field placeholder
    ///   - confirmTitle: Confirm button title (default: "OK")
    ///   - cancelTitle: Cancel button title (default: "Cancel")
    ///   - action: Action to perform when confirm is tapped
    /// - Returns: View with text field alert modifier
    func textFieldAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        text: Binding<String>,
        placeholder: String = "",
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        action: @escaping () -> Void
    ) -> some View {
        self.alert(title, isPresented: isPresented) {
            TextField(placeholder, text: text)
            Button(confirmTitle) {
                action()
            }
            Button(cancelTitle, role: .cancel) {}
        } message: {
            if let message = message {
                Text(message)
            }
        }
    }
    
    /// Show an alert with a text field and custom buttons
    /// - Parameters:
    ///   - isPresented: Binding to control alert visibility
    ///   - title: Alert title
    ///   - message: Optional alert message
    ///   - text: Binding to the text field value
    ///   - placeholder: Text field placeholder
    ///   - confirmTitle: Confirm button title
    ///   - cancelTitle: Cancel button title
    ///   - destructiveTitle: Optional destructive button title
    ///   - onConfirm: Action for confirm button
    ///   - onDestructive: Optional action for destructive button
    /// - Returns: View with text field alert modifier
    func textFieldAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        text: Binding<String>,
        placeholder: String = "",
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        destructiveTitle: String? = nil,
        onConfirm: @escaping () -> Void,
        onDestructive: (() -> Void)? = nil
    ) -> some View {
        self.alert(title, isPresented: isPresented) {
            TextField(placeholder, text: text)
            
            Button(confirmTitle) {
                onConfirm()
            }
            
            if let destructiveTitle = destructiveTitle, let onDestructive = onDestructive {
                Button(destructiveTitle, role: .destructive) {
                    onDestructive()
                }
            }
            
            Button(cancelTitle, role: .cancel) {}
        } message: {
            if let message = message {
                Text(message)
            }
        }
    }
    
    /// Show an alert with a secure text field for password input
    /// - Parameters:
    ///   - isPresented: Binding to control alert visibility
    ///   - title: Alert title
    ///   - message: Optional alert message
    ///   - text: Binding to the secure text field value
    ///   - placeholder: Text field placeholder
    ///   - confirmTitle: Confirm button title (default: "OK")
    ///   - cancelTitle: Cancel button title (default: "Cancel")
    ///   - action: Action to perform when confirm is tapped
    /// - Returns: View with secure text field alert modifier
    func secureTextFieldAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        text: Binding<String>,
        placeholder: String = "",
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        action: @escaping () -> Void
    ) -> some View {
        self.alert(title, isPresented: isPresented) {
            SecureField(placeholder, text: text)
            Button(confirmTitle) {
                action()
            }
            Button(cancelTitle, role: .cancel) {}
        } message: {
            if let message = message {
                Text(message)
            }
        }
    }
}

// MARK: - JetInputAlert Configuration

/// Configuration for a custom input alert
public struct JetInputAlertConfig {
    public let title: String
    public let message: String?
    public let placeholder: String
    public let confirmTitle: String
    public let cancelTitle: String
    public let isSecure: Bool
    
    public init(
        title: String,
        message: String? = nil,
        placeholder: String = "",
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        isSecure: Bool = false
    ) {
        self.title = title
        self.message = message
        self.placeholder = placeholder
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.isSecure = isSecure
    }
    
    /// Preset for renaming items
    public static func rename(placeholder: String = "New name") -> JetInputAlertConfig {
        JetInputAlertConfig(
            title: "Rename",
            message: "Enter a new name",
            placeholder: placeholder,
            confirmTitle: "Rename",
            cancelTitle: "Cancel"
        )
    }
    
    /// Preset for adding new items
    public static func addNew(itemType: String, placeholder: String = "") -> JetInputAlertConfig {
        JetInputAlertConfig(
            title: "Add \(itemType)",
            message: "Enter the \(itemType.lowercased()) name",
            placeholder: placeholder,
            confirmTitle: "Add",
            cancelTitle: "Cancel"
        )
    }
    
    /// Preset for password confirmation
    public static func passwordConfirm(message: String = "Please enter your password to continue") -> JetInputAlertConfig {
        JetInputAlertConfig(
            title: "Confirm Password",
            message: message,
            placeholder: "Password",
            confirmTitle: "Confirm",
            cancelTitle: "Cancel",
            isSecure: true
        )
    }
}

// MARK: - Preview

#if DEBUG
struct JetTextFieldAlert_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var showAlert = false
        @State private var inputText = ""
        
        var body: some View {
            VStack(spacing: 20) {
                Button("Show Text Field Alert") {
                    showAlert = true
                }
                
                Text("Input: \(inputText)")
                    .foregroundColor(.secondary)
            }
            .textFieldAlert(
                isPresented: $showAlert,
                title: "Enter Name",
                message: "Please provide a name for the item",
                text: $inputText,
                placeholder: "Name",
                action: {
                    print("Confirmed with: \(inputText)")
                }
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
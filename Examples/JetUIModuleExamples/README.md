# JetUI Module Examples

This example app is a module catalog for JetUI. It maps the top-level folders in `Sources/JetUI` to runnable or safe-to-inspect examples:

- Auth
- Components
- Core
- Extensions
- Features
- Firebase
- Models
- Network
- Resources
- Theme

Generate the Xcode project:

```sh
xcodegen generate --spec Examples/JetUIModuleExamples/project.yml --project Examples/JetUIModuleExamples
```

Open it:

```sh
open Examples/JetUIModuleExamples/JetUIModuleExamples.xcodeproj
```

Run the `JetUIModuleExamples` scheme on an iOS simulator.

Auth, Network, and Firebase pages intentionally avoid real external calls. They show local state, configuration shape, and safe snippets. Components, Features, Models, Resources, and Theme render real JetUI views.

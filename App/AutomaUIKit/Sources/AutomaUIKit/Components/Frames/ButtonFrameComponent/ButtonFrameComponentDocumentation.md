# ButtonFrameComponent

## Overview
The `ButtonFrameComponent` is the foundational component for creating consistent and flexible button elements across the AutomaUIKit framework. It simplifies the creation of buttons by providing configurable action, content, and appearance properties, allowing developers to build consistent buttons with minimal effort. This component is not meant to be used directly in application UIs, but as a base for wrapping button styles and behaviors within higher-level UI components in AutomaUIKit.

## Design
For design specifications, refer to the Figma link:
[ButtonFrame in Figma](https://www.figma.com/design/x5MkR0UFRMUkp0eiAXVbmy/AutomaUIKit?node-id=735-242&node-type=frame&t=JpVXz2NRkucAdA17-11).

## Usage

The `ButtonFrameComponent` can be easily integrated into your UI by using any of its multiple initializer variations. The examples below show how to use the component with different configurations for actions and content.

### Example: Basic Button
```swift
@State var isPaused = false
...
ButtonFrameComponent(action: { _ in
    print("Button was clicked")
    isPaused.toggle()
}) {
    Image(systemName: isPaused ? "play.fill" : "pause.fill")
        .resizable()
        .frame(width: 30, height: 30)
} onSelfAppear: { config in
    config.fillSpace = false
}
```

This example creates a button that toggles between a "play" and "pause" icon based on the `isPaused` state.

### Example: Managing the Button's Config
You can also manage the button's configuration from a parent view, allowing for dynamic updates.

```swift
@StateObject var buttonConfig = ButtonFrameComponentConfig()
...
ButtonFrameComponent(action: {
    print("Button was clicked")
}) {
    Text("Click Me")
}
...
// Modify the config in any method
func modifyButtonState() {
    buttonConfig.frameVariant = .allCases.random()
}
```

The `ButtonFrameComponent` allows the button's configuration to be managed externally, offering flexibility for dynamic adjustments.

## Parameters

| Property            | Type                                      | Description |
|---------------------|-------------------------------------------|-------------|
| `config`            | `ButtonFrameComponentConfig?`             | An optional configuration object that customizes the button's appearance. Defaults are provided if not specified. The configuration can be managed externally for more control. |
| `action`            | `Closure`                                 | A closure defining the button's action when clicked. The closure can either take or not take the `ButtonFrameComponentConfig` object, depending on the initializer used. |
| `content`           | `@ViewBuilder Closure`                    | A closure that defines the content of the button. The content can either take or not take the `ButtonFrameComponentConfig` object, depending on the initializer used. |
| `onSelfAppear`      | `Closure`                                 | A closure called when the button appears on screen, typically used to modify the component's appearance or behavior once it's rendered. |

## Guidelines

- **When to Use**: This component is ideal for creating base-level button components that are consistent across your app. It should not be used directly in the UI but instead be extended by higher-level components within AutomaUIKit that manage different button styles.
- **When Not to Use**: Avoid using this component directly for simple button implementations. Use higher-level wrapper components that manage its configuration and presentation. Also, avoid modifying its appearance outside of the provided configuration to maintain consistency.

## Customization

The `ButtonFrameComponent` is highly customizable through the `ButtonFrameComponentConfig` struct. This structure centralizes the configuration of the button's appearance and behavior, making it easy to customize different button styles consistently.

### onSelfAppear
The `onSelfAppear` closure allows customization of the button's configuration when it first appears on screen. This is especially useful for setting initial states or applying configurations that should be applied dynamically.

```swift
ButtonFrameComponent(action: { _ in
    print("Button clicked")
}) {
    Image(systemName: "play.fill")
        .resizable()
        .frame(width: 30, height: 30)
} onSelfAppear: { config in
    config.fillSpace = false
}
```

### Dynamic Content & Action Based on Configuration
The action and content closures can be customized to adapt to the current button configuration. Multiple initializers allow for flexible approaches, whether the configuration is passed directly or managed externally.

```swift
ButtonFrameComponent(action: {
    print("Button clicked")
}) { config in
    Image(systemName: config.frameVariant == .disabled ? "x.circle.fill" : "checkmark.square.fill")
}
```

In this example, the icon changes based on the button's `frameVariant`, which can be `disabled`, `generic`, or `rainbow`.

### Managing Button Configuration Externally
You can also manage the button's configuration externally by binding the configuration to a parent view's state.

```swift
@StateObject var buttonConfig = ButtonFrameComponentConfig()
...
ButtonFrameComponent(action: {
    print("Button clicked")
}) {
    Text("Click Me")
}
...
// Modify the properties of the config in any method
func modifyButtonState() {
    buttonConfig.frameVariant = .allCases.random()
}
```

This approach allows the parent view to control the button's configuration, ensuring consistency and reusability across different parts of the app.

## Initializer Variations

The `ButtonFrameComponent` provides several initializer options to allow flexible configurations for both the button's action and content. The variations enable you to use configuration, pass closures with or without it, and customize the component based on your needs.

### Initializer 1: Action Uses Config, Content Does Not
```swift
init(config: ButtonFrameComponentConfig? = nil,
     action: @escaping (ButtonFrameComponentConfig) -> Void,
     @ViewBuilder content: @escaping () -> Content,
     onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
```

### Initializer 2: Content Uses Config, Action Does Not
```swift
init(config: ButtonFrameComponentConfig? = nil,
     action: @escaping () -> Void,
     @ViewBuilder content: @escaping (ButtonFrameComponentConfig) -> Content,
     onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
```

### Initializer 3: Neither Action Nor Content Uses Config
```swift
init(config: ButtonFrameComponentConfig? = nil,
     action: @escaping () -> Void,
     @ViewBuilder content: @escaping () -> Content,
     onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
```

### Initializer 4: Both Action and Content Use Config
```swift
init(config: ButtonFrameComponentConfig? = nil,
     action: @escaping (ButtonFrameComponentConfig) -> Void,
     @ViewBuilder content: @escaping (ButtonFrameComponentConfig) -> Content,
     onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
```

Each initializer variation allows for flexible use cases, whether you're managing the configuration externally or passing it directly in the action and content closures.


Certainly! Here's the updated section for the `ButtonFrameComponentConfig` in the documentation. It explains the configuration structure and how to use it, providing context for the properties and their roles in customizing the button's appearance and behavior.

---

## ButtonFrameComponentConfig

The `ButtonFrameComponentConfig` class is a key part of customizing the `ButtonFrameComponent`. It defines the button's visual appearance and behavior, including how it responds to interactions and how its content is displayed. This configuration can be modified externally or passed as a parameter to customize individual buttons based on the specific needs of your application.

### Overview
The `ButtonFrameComponentConfig` class conforms to `ObservableObject` and is typically used with the `@StateObject` or `@ObservedObject` property wrapper in SwiftUI to manage the button's state. The class contains several published properties that allow you to adjust key aspects of the button's layout, such as its size, padding, background color, and corner radius.

### Properties

| Property                        | Type                  | Description |
|----------------------------------|-----------------------|-------------|
| `frameVariant`                  | `ButtonFrameVariants` | Defines the visual variant of the button. It can be one of the following:
  - `.generic` — A default button style.
  - `.disabled` — A button style for disabled state.
  - `.rainbow` — A button style with a gradient color background. |
| `fillSpace`                     | `Bool`                | Determines whether the button should fill the available space. When set to `true`, the button resizes to fill its container; if set to `false`, the button size is based on its content. |
| `isCircular`                    | `Bool`                | If set to `true`, the button becomes circular. When `true`, this property overrides the `roundness` property by setting it to `CGFloat.infinity`, creating a perfectly round button. |
| `roundness`                     | `CGFloat`             | Sets the corner radius of the button. If `isCircular` is set to `true`, this property is ignored. |
| `variantGenericBackground`      | `Color`               | Defines the background color for the `.generic` button variant. By default, it uses the primary color from the `DesignTokens`. |
| `variantDisabledBackground`     | `Color`               | Defines the background color for the `.disabled` button variant. By default, it uses a lighter variation of the primary color. |
| `defaultPadding`                | `CGFloat`             | Defines the default padding around the button's content. The padding is applied uniformly on all sides of the button. |

### Design Tokens
The configuration properties such as `variantGenericBackground`, `variantDisabledBackground`, `defaultPadding`, and `roundness` make use of design tokens. These tokens are centralized values that help maintain consistency across the design system. For example, `DesignTokens.colors.primary` refers to the primary color used across the app, and `DesignTokens.padding.button` provides the standard padding for buttons.

### Example: Customizing Button Appearance
You can modify the `ButtonFrameComponentConfig` to change the button's visual appearance based on your needs. Here is an example that shows how to customize a button's background color and padding:

```swift
@StateObject var buttonConfig = ButtonFrameComponentConfig()

ButtonFrameComponent(action: {
    print("Button clicked")
}) {
    Text("Click Me")
}
.onAppear {
    // Customize the button's configuration
    buttonConfig.frameVariant = .rainbow // Set the button to use a rainbow gradient background
    buttonConfig.fillSpace = false // Ensure the button does not fill the entire space
    buttonConfig.roundness = 10 // Apply custom roundness to the corners
}
```

In this example:
- The `frameVariant` is set to `.rainbow`, which will apply a gradient background to the button.
- The `fillSpace` property is set to `false`, ensuring the button size is based on its content.
- The `roundness` is set to `10`, creating rounded corners for the button.

### Example: Using ButtonFrameComponentConfig with `ButtonFrameComponent`
Here is an example where the `ButtonFrameComponentConfig` is used to customize the button behavior and appearance when creating a button:

```swift
@StateObject var buttonConfig = ButtonFrameComponentConfig()
...
ButtonFrameComponent(action: { _ in
    print("Button clicked")
}) {
    Text("Submit")
} onSelfAppear: { config in
    // Custom configuration when the button appears on screen
    config.frameVariant = .disabled
    config.fillSpace = false
}
```

In this example:
- The `onSelfAppear` closure allows you to modify the `ButtonFrameComponentConfig` when the button appears on screen. The `frameVariant` is set to `.disabled` to indicate the button is disabled.

### Best Practices for Customization
- **Use Default Configurations Where Possible**: The default `ButtonFrameComponentConfig` works for most use cases. Only customize it when you need specific behavior or appearance that differs from the default.
- **Manage Config Externally for Reusability**: If you need consistent styling across multiple buttons, manage the `ButtonFrameComponentConfig` externally and pass it to each `ButtonFrameComponent`.
- **Avoid Overwriting Design Tokens**: Where possible, stick to the pre-defined design tokens for colors and padding to maintain consistency across your application. Modify them only when necessary for specific design requirements.

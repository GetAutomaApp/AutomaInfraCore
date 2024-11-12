# ButtonFrameComponent

## Overview
<!-- Give a reason behind this component & what it is doing -->
This Component functions as a base-point for most of the buttons created in AutomaUIKit.
This component aims to simplify the implementation & consistency aspect of any button component that implements the `ButtonFrameComponent`

## Design
LINK: [ButtonFrame](https://www.figma.com/design/x5MkR0UFRMUkp0eiAXVbmy/AutomaUIKit?node-id=735-242&node-type=frame&t=JpVXz2NRkucAdA17-11)

## Usage
<!-- Explain how to use the component here -->
The component can be used via the examples provided below, or by observing the `ButtonFrameComponent_Previews.swift` file for practicle usage examples!

```swift
@State let isPaused = false
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

## Props/Parameters
| Property | Type | Description |
|----------|------|-------------|
| `config` | ButtonFrameComponentConfig? | Provides a default configuration the the component. This can be overwritten on initialization via one of the init variations. The component allows the parent to manage the config for more advanced customisation. |
| `action` | CLOSURE | A closure to determine what the button should do, the initializer has 2 implementations of exposing & not exposing the `config` |
| `content` | CLOSURE ViewBuilder | A ViewBuilder which manages the internal content of the button. Initializer has 2 implementations of exposing & not exposing the `config`. |
| `onSelfAppear` | CLOSURE | Optional input to manage the content which happens once the component appears. Internal implementation uses `onAppear` modifier |

## Guidelines
<!-- Explain when and when not to use the component based on past experience -->
- Don't use this directly in the UI of an application, but rather make use of components wrapping this Frame, buttons should be created and managed via AutomaUIKit!
- Extending this button can be done with `.buttonStyle` and creating a new component.

## Customization
<!-- Explain how users can customize the component via the "Config" object in ButtonFrameComponentConfig Struct -->
Customisation makes this component highly reusable, as well as centralizing the implementation of most button components. Here is how to take full advantage of the config.

**onSelfAppear**: </br>
`onSelfAppear` is a closure implemented by one of the initializers of the component. It allows you to modify the component, without having the parent manage the config.

```swift
@State let isPaused = false
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

**action & content**: </br>
the `action` and `content` closures have multiple initializers, which allows you to access the internal button config to do customizations like change state `onClick` or render content based on internal state, or the state being managed internally.

Here is an example of making a button show a different icon when it the state of disabled:
```swift
ButtonFrameComponent(action: {
    print("Button was clicked")
}) { config in
        Image(systemName: config.frameVariant == .disabled ? "x.circle.fill" : "checkmark.square.fill")
    }
```

You can further access the state by making the parent component manage the config. Here is an example of that:
```swift
@StateObject var buttonConfig = ButtonFrameComponentConfig()
...
ButtonFrameComponent(action: {
    print("Button was clicked")
}) {
    Text("Click Me")
}
...
// Modify the properties of the config in sub-methods
func modifyButtonState() {
    buttonConfig.frameVariant = .allCases.random()
}
```

This is a simple addition
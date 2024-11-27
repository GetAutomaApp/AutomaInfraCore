# InfoPairComponent

## Overview
<!-- Give a reason behind this component & what it is doing -->
The InfoPairComponent functions as an information excerpt to be displayed to the user. This component will have many varients which will represent many variations of this component, including username bio, title variants and more!

The `InfoPairComponent` is a foundational component used to create info pairs which consists of a title & subtext components. This component has many varients, allowing you to effectively create any style of `InfoPair` you could possibly want. AutomaUIKit extends the InfoPair component on many occasions to create more specialized implementations.

## Design
LINK: [FIGMA](https://www.figma.com/design/x5MkR0UFRMUkp0eiAXVbmy/AutomaUIKit?node-id=635-397)

## Usage
<!-- Explain how to use the component here -->
<!-- Ensure to provide at-least one example per initializer to make the user understand the scope of the component -->
<!-- Add one image per initializer (This is UI after all) -->
The `InfoPair` component keps customisability in mind, hence the initialisers being flexible by allowing direct input, or via an externally managed observable object named `InfoPairComponentConfig`

### Example: All defaults
The default initializer has default values for both the title and subtext parts of this component, so be careful!
```swift
InfoPairComponent()
```

### Example: Externally managed config
This allows you to have an external config which can be modified from the outside, useful for setting default properties or extending this component.

The config is optional (has a default value), and you can also pass in `title` and `description` params into this component if you want to use the simple implementation!
```swift
InfoPairComponent(config: .init())
```

> [!NOTE]
> Each of these initializers allows you to pass a closure named `onSelfAppear` which exposes the config used on the inside (works with an external config as well). To allow for code execution & component customization!
```swift
InfoPairComponent(...) { config in
    print("do something with me \(config)")
}
```

## Props/Parameters
| Property | Type | Description |
|----------|------|-------------|
| `config` | InfoPairComponentConfig? | Configuration for the component. |
| `title` | string? | The title for the component |
| `description` | string? | The description for the component |
| `onSelfAppear` | ((InfoPairComponentConfig) -> ())? | A closure to execute any code / modify the component |

## Guidelines
<!-- Explain when and when not to use the component based on past experience -->
- **When to Use**: This component should only be used when the text hierarchy could be maintained

## Customization
<!-- Explain how users can customize the component via the "Config" object in InfoPairComponentConfig Struct -->
This component can be customised via the `InfoPairComponentConfig`.

**Current Variations**:
- `.generic`

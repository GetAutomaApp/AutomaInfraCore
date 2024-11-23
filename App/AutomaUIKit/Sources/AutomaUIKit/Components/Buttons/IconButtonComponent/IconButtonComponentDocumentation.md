# IconButtonComponent

## Overview
`IconButtonComponent` is a versatile button that displays an icon, with customizable styles and behaviors. It is designed to provide a flexible and reusable solution for creating icon-based buttons in your app. The component allows for various button shapes (like square, circle, pill, and generic), different icon styles, and supports both disabled and enabled states. It also allows for customization through the `IconButtonComponentConfig` configuration.

## Design
**LINK:** [Figma Design File](https://www.figma.com/design/x5MkR0UFRMUkp0eiAXVbmy/AutomaUIKit?node-id=635-596)  
This component is designed to be simple yet flexible, offering multiple visual variants to fit different design needs. It can be adapted to fit your app's UI style, with the ability to change its appearance and action behavior via its configuration object.

## Usage

### Basic Usage with External Configuration
```swift
let iconConfig = IconButtonComponentConfig()
iconConfig.icon = .heart // Assigning an icon from DesignIconsEnum
iconConfig.variant = .circle // Making the button circular

IconButtonComponent(config: iconConfig, onSelfAppear: { config in
    // Custom logic when the button appears
}, action: { config in
    // Action when button is tapped
})
```

### Usage with Default Internal Configuration
```swift
IconButtonComponent(
    defaultIcon: .search, // Default icon
    onSelfAppear: { config in
        // Custom logic when the button appears
    },
    action: { config in
        // Action when button is tapped
    }
)
```

### Usage with Action Closure Only (No Configuration)
```swift
IconButtonComponent(
    onSelfAppear: { config in
        // Custom logic when the button appears
    },
    defaultIcon: .home, // Default icon
    action: {
        // Action when button is tapped
        print("Home button tapped")
    }
)
```

## Props/Parameters

| Property        | Type                        | Description                                                                                   |
|-----------------|-----------------------------|-----------------------------------------------------------------------------------------------|
| `config`        | `IconButtonComponentConfig`  | Configuration for the component. Defines properties like the icon, variant, and disabled state. |
| `onSelfAppear`  | `(IconButtonComponentConfig) -> Void` | Closure to execute when the button appears on the screen.                                       |
| `action`        | `(IconButtonComponentConfig) -> Void` | Closure to execute when the button is tapped.                                                   |

## Guidelines

### When to Use:
- **Use this component when you need a simple button with an icon** that fits various styles (e.g., circular, square, pill) and can be easily customized.
- **Ideal for navigation buttons**, toolbars, or any action button that requires an icon and optional text or background customization.
- **Good for accessibility**: The component supports customizable disabled states, making it adaptable for interactive or non-interactive buttons.
  
### When Not to Use:
- **Avoid using it for complex buttons** that require additional controls or text input. This component is primarily for displaying an icon and handling basic tap actions.
- **Do not use this component if you need a button with complex states** (like loading indicators, multi-step processes, etc.). This is meant for simple actions.

## Customization

`IconButtonComponent` is highly customizable via the `IconButtonComponentConfig` struct. Here’s how you can customize the component’s appearance and behavior:

### Icon Customization
You can assign any value from the `DesignIconsEnum` to the `icon` property:
```swift
config.icon = .home // Assign an icon
```

### Button Variant
Control the button's shape by setting the `variant` property:
```swift
config.variant = .circle // Circular button
config.variant = .square // Square button
config.variant = .pill   // Pill-shaped button
```

### Disabled State
Manage the button's disabled state by setting the `isDisabled` property:
```swift
config.isDisabled = true // Disables the button, preventing interaction
```

### Padding & Spacing
The component automatically adjusts padding based on the variant. However, you can customize it further by modifying the `defaultPadding` property in the config:
```swift
config.defaultPadding = DesignTokens.padding.button // Custom padding
```

### Roundness and Corner Radius
For each variant, the button will adjust the `roundness` and `isCircular` properties to fit the design. These properties can be further customized as needed.

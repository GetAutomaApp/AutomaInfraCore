// PropertyEditor.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/**
 The AnyKeyPath struct represents a type reased keypath which both has getter & setter methods.
 This wrapper aims to simplify the usage of most types by allowing you to if/else over them.

 This struct does the following:
 - Has an initiializer to manually initialize all properties
 - Provides an initializer to initialize the code via a KeyPath
 */
public struct AnyKeyPath<TheObservedObject, TheValueType> {
    public let label: String
    public let get: (TheObservedObject) -> TheValueType
    public let set: (inout TheObservedObject, TheValueType) -> Void
    public let type: Any.Type

    // MARK: - 1. First initializer. Initialize this struct by providing a writable keypath

    /**
     Initializes an `AnyKeyPath` where the `get` and `set` properties makes use of KeyPath syntax

      - Parameter label: The friendly **label** you want to represent to the user in the UI
      - Parameter keyPath: A `WritableKeyPath` reference from an `ObservableObject`
      */
    public init<ObservableWrappedValueType>(
        _ label: String,
        keyPath: WritableKeyPath<TheObservedObject, ObservableWrappedValueType>
    ) where ObservableWrappedValueType: Any {
        self.label = label
        get = { object in object[keyPath: keyPath] as! TheValueType }
        set = { object, value in
            var mutableObject = object
            mutableObject[keyPath: keyPath] = value as! ObservableWrappedValueType
        }
        type = ObservableWrappedValueType.self
    }
}

/**
 Renders a SwiftUI view to edit a property by slider or text input.

 - Parameter value: A binding to the `CGFloat` Value being edited.
 - Parameter label: The label being renered out on the client.
 - Parameter max: The maximum that the `value` property is allowed to be.
 */
private struct PaddingSliderInput: View {
    @Binding var value: CGFloat
    public let label: String
    public let max: CGFloat = 30

    public var body: some View {
        HStack {
            Text("\(label):")
            Slider(value: $value, in: 0 ... max, step: 1)
                .padding(.leading)
            TextField("", value: $value, formatter: NumberFormatter())
                .onChange(of: value) { oldValue, newValue in
                    if oldValue != newValue {
                        value = newValue
                    }
                }
                .frame(width: 30)
        }
    }
}

/**
 Renders a SwiftUI view to edit edge insets via a binding to that value.
 */
public struct PaddingEditor: View {
    @Binding public var edgeInsets: EdgeInsets

    public var body: some View {
        VStack(spacing: 16) {
            PaddingSliderInput(value: $edgeInsets.top, label: "Top")
            PaddingSliderInput(value: $edgeInsets.leading, label: "Left")
            PaddingSliderInput(value: $edgeInsets.bottom, label: "Bottom")
            PaddingSliderInput(value: $edgeInsets.trailing, label: "Right")
        }
        .padding()
    }
}

internal struct CGSizeEdtior: View {
    @Binding var cgSize: CGSize

    public var body: some View {
        HStack {
            PaddingSliderInput(value: $cgSize.width, label: "W")
            Spacer()
            PaddingSliderInput(value: $cgSize.height, label: "H")
        }
    }
}

/**
 Renders a SwiftUI Segmented Picker allowing you to switch between enum values.

 - Parameter value: The Enum value you want to keep in sync.
 - Parameter cases: All the cases that you want to allow the editor to switch to.
 */
public struct EnumPropertyView<E: CaseIterable & RawRepresentable & Hashable>: View where E.RawValue == String {
    @Binding public var value: E
    public let cases: [E]

    public var body: some View {
        Picker("Select", selection: $value) {
            ForEach(cases, id: \.self) { variant in
                if let variant = variant as? DesignIcons {
                    variant.image
                } else {
                    Text(variant.rawValue)
                }
            }
        }.pickerStyle(.segmented)
    }

    private func isDesignIcon(_ t: some Any) -> Bool {
        t is DesignIcons
    }
}

/**
 Renders a SwiftUI view which allows you to modify various properties on a StateObject / ObservableObject.

 - Parameter object: The ObservableObject you want this `PropertyEditor` to modify.
 - Parameter properties: All the properties you want rendered out from the **object** parameter.
 - Parameter viewwer: A SwiftUI view closure to render out any additional content.

 Notes:
 - Never pass an AnyKeyPath referencing another ObservableObject. Reference each property separately.
 - Supported types are listed in the description of the `propertyRow` method of this struct
 - All Enums, and extra items should be passed into the `viewer` property

 This method currently isn't perfect but it does reduce the code duplication by 10 fold.
 */
public struct PropertyEditor<T: ObservableObject, Content: View>: View {
    @ObservedObject var object: T
    public let properties: [[AnyKeyPath<T, Any>]]

    @ViewBuilder public let viewer: () -> Content

    public var body: some View {
        VStack {
            viewer().padding()

            Form {
                ForEach(properties.indices, id: \.self) { index in
                    HStack {
                        ForEach(properties[index].indices, id: \.self) { item in
                            propertyRow(for: properties[index][item])
                        }
                    }
                }
            }
        }.preferredColorScheme(.dark)
    }

    /**
     Builds a SwiftUI View for a form element which modifies its property.

     - Parameter property: The `AnyKeyPath` object you want to generate a row for.

     Supported Types: Strings, Integers, Booleans, Doubles, CGFloats, EdgeInsets, Colors
     Types Coming Soon: Arrays (Generic), Dictionaries

     TODO: Add support for specifying modifications in the AnyKeyPath initializer
     */
    @ViewBuilder
    private func propertyRow(for property: AnyKeyPath<T, Any>) -> some View {
        // TODO: Handle nested Observable Objects
        if property.type == String.self {
            let value = property.get(object) as! String
            HStack {
                Text("\(property.label):")
                TextField(property.label, text: Binding(
                    get: { value },
                    set: { newValue in
                        var mutableObject = object
                        property.set(&mutableObject, newValue)
                    }
                ))
            }
        } else if property.type == Int.self {
            let value = property.get(object) as! Int
            Stepper(
                "\(property.label): \(value)",
                value: Binding(
                    get: { value },
                    set: { newValue in
                        var mutableObject = object
                        property.set(&mutableObject, newValue)
                    }
                ),
                in: 0 ... 100
            )
        } else if property.type == Bool.self {
            let value = property.get(object) as! Bool
            Toggle("\(property.label): ", isOn: Binding(
                get: { value },
                set: { newValue in
                    var mutableObject = object
                    property.set(&mutableObject, newValue)
                }
            ))
        } else if property.type == Double.self {
            let value = property.get(object) as! Double
            Slider(
                value: Binding(
                    get: { value },
                    set: { newValue in
                        var mutableObject = object
                        property.set(&mutableObject, newValue)
                    }
                ),
                in: 0 ... 100
            ) {
                Text("\(property.label): \(value, specifier: "%.1f")")
            }
        } else if type(of: property.get(object)) == EdgeInsets.self {
            let value = property.get(object) as! EdgeInsets
            PaddingEditor(edgeInsets: Binding(
                get: { value },
                set: { newValue in
                    var mutableObject = object
                    property.set(&mutableObject, newValue)
                }
            ))
        } else if property.type == CGFloat.self {
            let value = property.get(object) as! CGFloat
            PaddingSliderInput(value: Binding(get: { value }, set: { newValue in
                var mutableObject = object
                property.set(&mutableObject, newValue)
            }),
            label: property.label)
        } else if property.type == Color.self {
            let value = property.get(object) as! Color
            ColorPicker("\(property.label):", selection: Binding(get: {
                value
            }, set: { newValue in
                var mutableObject = object
                property.set(&mutableObject, newValue)
            }))
        } else if property.type == CGSize.self {
            let value = property.get(object) as! CGSize
            CGSizeEdtior(cgSize: Binding(
                get: { value },
                set: { newValue in
                    var mutableObject = object
                    property.set(&mutableObject, newValue)
                }
            ))
        } else {
            Text("\(property.label)")
        }
    }
}

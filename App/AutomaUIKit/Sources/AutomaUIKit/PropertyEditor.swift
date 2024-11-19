import SwiftUI

struct AnyKeyPath<T, V> {
  let label: String
  let get: (T) -> V
  let set: (inout T, V) -> Void
  let type: Any.Type

  init(
    _ label: String,
    _ get: @escaping (T) -> V,
    _ set: @escaping (inout T, V) -> Void,
    _ type: Any
  ) {
    self.label = label
    self.get = get
    self.set = set
    self.type = type as! any Any.Type
  }

  init<U>(_ label: String, keyPath: WritableKeyPath<T, U>) where U: Any {
    self.label = label
    get = { object in object[keyPath: keyPath] as! V }
    set = { object, value in
      var mutableObject = object
      mutableObject[keyPath: keyPath] = value as! U
    }
    type = U.self
  }
}

struct PaddingSliderInput: View {
  @Binding var value: CGFloat
  let label: String

  var body: some View {
    HStack {
      Text("\(label):")
      Slider(value: $value, in: 0 ... 30, step: 1)
        .padding(.leading)
      TextField("", value: $value, formatter: NumberFormatter())
        .keyboardType(.decimalPad)
        .onChange(of: value) { newValue in
          value = min(max(newValue, 0), 100)
        }
        .frame(width: 30)
    }
  }
}

struct PaddingEditor: View {
  @Binding var edgeInsets: EdgeInsets

  var body: some View {
    VStack(spacing: 16) {
      PaddingSliderInput(value: $edgeInsets.top, label: "Top")
      PaddingSliderInput(value: $edgeInsets.leading, label: "Left")
      PaddingSliderInput(value: $edgeInsets.bottom, label: "Bottom")
      PaddingSliderInput(value: $edgeInsets.trailing, label: "Right")
    }
    .padding()
  }
}

// struct EnumPropertyView<E: CaseIterable & RawRepresentable & Hashable & RandomAccessCollection>: View where
// E.RawValue == String {
//    @Binding var value: E
//
//    var body: some View {
//        Picker("", selection: $value) {
//            ForEach(E.allCases, id: \.self) { enumCase in
//                Text(enumCase.rawValue)
//            }
//        }
//    }
// }

struct EnumPropertyView<E: CaseIterable & RawRepresentable & Hashable>: View where E.RawValue == String {
  @Binding var value: E
  let cases: [E]

  var body: some View {
    Picker("Select", selection: $value) {
      ForEach(cases, id: \.self) { variant in
        Text(variant.rawValue)
      }
    }.pickerStyle(.segmented)
  }
}

struct PropertyEditor<T: ObservableObject, Content: View>: View {
  @ObservedObject var object: T
  let properties: [[AnyKeyPath<T, Any>]]

  let viewer: () -> Content

  var body: some View {
    Form {
      viewer()

      ForEach(properties.indices, id: \.self) { index in
        HStack {
          ForEach(properties[index].indices, id: \.self) { item in
            propertyRow(for: properties[index][item])
          }
        }
      }
    }
  }

  @ViewBuilder
  func propertyRow(for property: AnyKeyPath<T, Any>) -> some View {
    // Check if the property is another ObservableObject (We will then make sure that we recursively do this!)
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
      // Create a padding editor
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
      // Colors (Pull from design colors & color picker)
      let value = property.get(object) as! Color
      ColorPicker("\(property.label):", selection: Binding(get: {
        value
      }, set: { newValue in
        var mutableObject = object
        property.set(&mutableObject, newValue)
      }))
    }
  }
}

func getAllEnumCases<T>(from value: T) -> [T] where T: CaseIterable & RawRepresentable {
  if let enumValue = value as? T.Type {
    return enumValue.allCases as! [T]
  }
  return []
}

class Person: ObservableObject {
  @Published var name: String = "John Doe"
  @Published var age: Int = 30
  @Published var isStudent: Bool = false
  @Published var gpa: Double = 3.5
}

struct ContentView: View {
  @StateObject private var person = Person()
  @StateObject var buttonConfig: ButtonFrameComponentConfig = .init()

  var body: some View {
    PropertyEditor(
      object: buttonConfig,
      properties: [
        [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
        [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
        [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
        [AnyKeyPath("Roundness", keyPath: \.roundness)],
        [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
        [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
      ]
    ) {
      VStack {
        HStack {
          ButtonFrameComponent(config: buttonConfig, action: {
            print("Clicked Me")
          }) {
            Text("Hello, World")
          }

          ButtonFrameComponent(config: buttonConfig, action: {
            print("Clicked Me")
          }) {
            Image(systemName: "play.fill")
          }
        }

        EnumPropertyView(
          value: $buttonConfig.frameVariant,
          cases: ButtonFrameVariants.allCases
        )
      }
    }
  }
}

#Preview {
  ContentView()
}

// CrimsonFontModifier_Previews.swift
// was created on 11/23/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

// TODO:
import SwiftUI

// Add a preview per state difference (No need to add all states)

struct CrimsonFontModifier_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

struct TestView: View {
    var body: some View {
        ContentView()
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            // Using the registered "CrimsonText-Bold" font from SwiftGen enum
            Text("This is bold Crimson Text!")
                .font(FontFamily.CrimsonText.bold.swiftUIFont(size: 20.0))
                .padding()

            // Using "CrimsonText-Regular" font from SwiftGen enum
            Text("This is regular Crimson Text!")
                .font(FontFamily.CrimsonText.regular.swiftUIFont(size: 18))
                .padding()

            // Using "CrimsonText-Italic" font from SwiftGen enum
            Text("This is italic Crimson Text!")
                .font(FontFamily.CrimsonText.italic.swiftUIFont(size: 20))
                .padding()
            
            // Using "CrimsonText-BoldItalic" font from SwiftGen enum
            Text("This is italic bold Crimson Text!")
                .font(FontFamily.CrimsonText.boldItalic.swiftUIFont(size: 20))
                .padding()

            // Using "CrimsonText-SemiBold" font from SwiftGen enum
            Text("This is semi-bold Crimson Text!")
                .font(FontFamily.CrimsonText.semiBold.swiftUIFont(size: 22))
                .padding()
            
            // Using "CrimsonText-SemiBoldItalic" font from SwiftGen enum
            Text("This is italic semi-bold Crimson Text!")
                .font(FontFamily.CrimsonText.semiBoldItalic.swiftUIFont(size: 22))
                .padding()
        }
    }
}

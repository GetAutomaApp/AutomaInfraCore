// FontTableFontModifier_Previews.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct FontTableFontModifier_Previews: PreviewProvider {
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
        VStack(alignment: .leading) {
            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Headings.head1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Headings.head2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Headings.head3)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Headings.head4)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Headings.head5)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Headings.head6)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Body.body1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Body.body2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Body.body3)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Body.body4)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Meta.label1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Meta.label2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Meta.caption1)

        }.padding()
    }
}

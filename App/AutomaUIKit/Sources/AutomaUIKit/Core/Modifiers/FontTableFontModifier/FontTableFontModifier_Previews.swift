// FontTableFontModifier_Previews.swift
// Copyright (c) 2025 GetAutomaApp
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
                .fontTableFont(FontTable.Crimson.Headings.head1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head3)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head4)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head5)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head6)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Body.body1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Body.body2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Body.body3)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Body.body4)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Meta.label1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Meta.label2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Meta.caption1)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head1)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head2)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head3)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head4)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head5)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head6)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Body.body1)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Body.body2)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Body.body3)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Body.body4)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Meta.label1)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Meta.label2)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Meta.caption1)

        }.padding()
    }
}

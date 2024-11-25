// InfoPairComponent.swift
// was created on 11/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct InfoPairComponent: View {
  var config: InfoPairComponentConfig = .init()

  var body: some View {
    VStack(alignment: .leading) {
      Text("Enter a title here").fontTableFont(FontTable.Headings.head4)
      Text("Enter a 3 line / 2 line description here").fontTableFont(FontTable.Body.body1)
    }
  }
}

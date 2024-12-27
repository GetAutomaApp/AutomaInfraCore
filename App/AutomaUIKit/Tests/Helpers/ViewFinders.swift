// ViewFinders.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  ViewFinders.swift
//  AutomaUIKit
//
//  Created by Simon Ferns on 11/26/24.
//
import SwiftUI
import ViewInspector

extension InspectableView {
    func find(textWithFont font: Font) throws -> InspectableView<ViewType.Text> {
        try find(ViewType.Text.self, where: {
            try $0.attributes().font() == font
        })
    }
}

// ButtonFrameComponent_Previews.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp. All rights reserved.

import SwiftUI

struct ButtonFrameComponent_Previews: PreviewProvider {
    static var previews: some View {
        ButtonFrameComponent_PreviewsView()
    }
}

struct AutoButtonVariationsView: View {
    @StateObject var buttonController: ButtonFrameComponentConfig = .init()
    @State private var isTimerActive = false

    let switchDelay: TimeInterval = 0.5

    var body: some View {
        HStack {
            ButtonFrameComponent(config: buttonController, action: { config in
                config.isCircular.toggle()
                config.frameVariant = .disabled
            }) { _ in
                ProgressView()
            } onSelfAppear: { _ in
                startChangingVariant()
            }

            Spacer()

            ButtonFrameComponent(action: { _ in
                isTimerActive ? stopChangingVariant() : startChangingVariant()
            }) {
                Image(systemName: isTimerActive ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
            } onSelfAppear: { config in
                config.fillSpace = false
            }
        }
    }

    func startChangingVariant() {
        if isTimerActive {
            return
        }

        isTimerActive = true

        DispatchQueue.main.asyncAfter(deadline: .now() + switchDelay) {
            updateVariant()
        }
    }

    func updateVariant() {
        buttonController.frameVariant = .allCases.randomElement()!
        buttonController.isCircular = .random()
        buttonController.fillSpace = .random()

        if isTimerActive {
            DispatchQueue.main.asyncAfter(deadline: .now() + switchDelay) {
                updateVariant()
            }
        }
    }

    func stopChangingVariant() {
        isTimerActive = false
    }
}

struct ButtonFrameComponent_PreviewsView: View {
    var body: some View {
        ScrollView {
            AutoButtonVariationsView()
        }
        .padding()
    }
}

// struct ButtonFrameComponent_PreviewsView: View {
//    var body: some View {
//        ZStack {
//            Color.green
//            VStack {
//                Spacer()
//                ZStack {
//                    Color.black.frame(height: 350)
//                    VStack {
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text("Enter a title here")
//                                    .foregroundStyle(.white)
//                                    .font(.title)
//
//                                Text("Enter a 3 line / 2 line description here")
//                                    .foregroundStyle(.white)
//                                    .font(.subheadline)
//                            }
//
//                            Spacer()
//                        }
//
//                        Spacer()
//                        ButtonFrameComponent(action: { _ in }) { _ in
//                            Image(systemName: "arrow.right")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 30)
//                                .padding(5)
//                        }
//                        Spacer().frame(height: 20)
//                    }
//                    .padding(30)
//                }
//                .frame(height: 350)
//            }
//        }
//        .ignoresSafeArea()
//    }
// }

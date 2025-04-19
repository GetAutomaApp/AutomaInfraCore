// RandomService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

internal enum RandomService {
    public static let animals = [
        "Dog",
        "Cat",
        "Bird",
        "Elephant",
        "Penguin",
        "Panda",
        "Zebra",
        "Walrus",
        "Otter",
        "Kangaroo",
        "Moose",
        "Donkey",
        "Hedgehog",
    ]

    public static let objects = [
        "Chair",
        "Table",
        "Spoon",
        "Toaster",
        "Cup",
        "Waffle",
        "Lollipop",
        "Bubble",
        "Cupcake",
        "Biscuit",
        "Sprinkle",
        "Banjo",
        "Popsicle",
        "Doodle",
    ]

    public static let adjectives = [
        "Whimsical",
        "Cute",
        "Adorable",
        "Funny",
        "Cool",
        "Awesome",
        "Fluffy",
        "Bouncy",
        "Snuggly",
        "Sparkly",
        "Wiggly",
        "Wacky",
        "Bizarre",
        "Cheeky",
        "Peachy",
        "Fizzy",
        "Dizzy",
        "Goofy",
        "Fuzzy",
        "Smiley",
        "Chirpy",
    ]

    public static let moods = [
        "Snappy",
        "Sunny",
        "Quirky",
        "Jolly",
        "Happy",
        "Bright",
        "Playful",
        "Glittery",
        "Dreamy",
        "Friendly",
    ]

    public static let allWords = adjectives + moods + animals + objects

    static func randomUsername() -> String {
        let mood = moods.randomElement()!
        let adjective = adjectives.randomElement()!
        let object = objects.randomElement()!

        let randomAppend = UUID().uuidString.split(separator: "-").first!.prefix(4)

        return "\(mood)\(adjective)\(object)\(randomAppend)"
    }

    static func randomCode() -> String {
        let first = allWords.randomElement()!.lowercased()
        let second = allWords.randomElement()!.lowercased()

        return "\(first)-\(second)"
    }
}

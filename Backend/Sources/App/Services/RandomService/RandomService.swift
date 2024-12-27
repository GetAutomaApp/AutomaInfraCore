// RandomService.swift
// was created on 12/27/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

enum RandomService {
    static let whimsicalWords = [
        "Whimsical",
        "Giraffe",
        "Banana",
        "Monkey",
        "Penguin",
        "Elephant",
        "Cute",
        "Adorable",
        "Funny",
        "Cool",
        "Awesome",
        "Puppy",
        "Kitten",
        "Chair",
        "Dog",
        "Cat",
        "Bird",
        "Table",
        "Spoon",
        "Vegetable",
        "Fruit",
        "Animal",
        "Vehicle",
        "Potato",
        "Carrot",
        "Apple",
        "Orange",
        "Rainbow",
        "Giggle",
        "Fluffy",
        "Bouncy",
        "Ducky",
        "Zebra",
        "Cloudy",
        "Taco",
        "Pickle",
        "Snuggle",
        "Sparkle",
        "Wiggly",
        "Froggy",
        "Cupcake",
        "Bubble",
        "Biscuit",
        "Squishy",
        "Jelly",
        "Marshmallow",
        "Sprinkle",
        "Huggy",
        "Doodle",
        "Slinky",
        "Wacky",
        "Bizarre",
        "Lollipop",
        "Quirky",
        "Scooter",
        "Chuckle",
        "Cuddle",
        "Plushy",
        "Panda",
        "Moose",
        "Donkey",
        "Blossom",
        "Sunshine",
        "Snappy",
        "Jumpy",
        "Chirpy",
        "Toaster",
        "Banjo",
        "Twinkle",
        "Cheeky",
        "Peachy",
        "Fizzy",
        "Slinky",
        "Dizzy",
        "Goofy",
        "Muffin",
        "Walrus",
        "Otter",
        "Silly",
        "Candy",
        "Cup",
        "Waffle",
        "Penguin",
        "Kangaroo",
        "Smiley",
        "Lemon",
        "Fuzzy",
        "Pumpkin",
        "Popsicle",
        "Starfish",
        "Pineapple",
        "Doodlebug",
        "Cherry",
        "Mango",
        "Snickerdoodle",
        "Dandelion",
        "Hedgehog",
        "Pluto",
    ]

    static func randomUsername() -> String {
        let first = whimsicalWords.randomElement()!
        var second: String

        repeat {
            second = whimsicalWords.randomElement()!
        } while second == first

        let randomAppend = UUID().uuidString.split(separator: "-").first!.prefix(4)

        let username = "\(first)-\(second)-\(randomAppend)"

        return username
    }

    static func randomCode() -> String {
        let first = whimsicalWords.randomElement()!.lowercased()
        let second = whimsicalWords.randomElement()!.lowercased()

        let code = "\(first)-\(second)"
        return code
    }
}

//
//  Deck.swift
//  DeckKit
//
//  Created by Daniel Saidi on 2020-08-31.
//  Copyright © 2020-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This struct represents a deck of items, with a unique id, a
 name, and a collection of ``DeckItem`` items.
 */
public struct Deck<Item: DeckItem>: Identifiable, Equatable {
    
    /**
     Create a deck with items.
     
     - Parameters:
       - id: The unique id of the deck, by default `UUID()`.
       - name: The name of the deck, by default `.empty`.
       - items: The items to include in the deck.
     */
    public init(
        id: UUID = UUID(),
        name: String = "",
        items: [Item]
    ) {
        self.id = id
        self.name = name
        self.items = items
    }
    
    /// The unique id of the deck.
    public let id: UUID
    
    /// The name of the deck.
    public let name: String
    
    /// The items that are added to the deck.
    public var items: [Item]
}

public extension Deck {
    
    /// The index of a certain item, if any.
    func index(of item: Item) -> Int? {
        items.firstIndex { $0.id == item.id }
    }
    
    /// Move the first item to the back of the deck.
    mutating func moveFirstItemToBack() {
        guard let item = items.first else { return }
        moveToBack(item)
    }
    
    /// Move the last item to the front of the deck.
    mutating func moveLastItemToFront() {
        guard let item = items.last else { return }
        moveToFront(item)
    }
    
    /// Move an item to the back of the deck.
    mutating func moveToBack(_ item: Item) {
        guard let index = index(of: item) else { return }
        let topItem = items.remove(at: index)
        items.append(topItem)
    }

    /// Move an item to the front of the deck.
    mutating func moveToFront(_ item: Item) {
        guard let index = index(of: item) else { return }
        if items[0].id == item.id { return }
        let topItem = items.remove(at: index)
        items.insert(topItem, at: 0)
    }

    /// Shuffle the deck.
    mutating func shuffle() {
        items.shuffle()
    }
}



private struct Hobby: DeckItem {
    
    var name: String
    var text: String

    var id: String { name }
}

private extension Deck {
    
    static var hobbies: Deck<Hobby> {
        .init(
            name: "Hobbies",
            items: [
                Hobby(name: "Music", text: "I love music!"),
                Hobby(name: "Movies", text: "I also love movies!"),
                Hobby(name: "Programming", text: "Not to mention programming!")
            ]
        )
    }
}

#Preview {
    
    struct MyView: View {

        @State var deck = Deck<Hobby>.hobbies

        var body: some View {
            DeckView(deck: $deck) { hobby in
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .fill(.blue)
                    .overlay(Text(hobby.name))
                    .shadow(radius: 10)
            }
            .padding()
            .deckViewConfiguration(
                .init(direction: .down)
            )
        }
    }
    
    return MyView()
}

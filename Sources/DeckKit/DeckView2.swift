//
//  DeckView.swift
//  DeckKit
//
//  Created by Daniel Saidi on 2020-08-31.
//  Copyright © 2020-2024 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(visionOS)
    import SwiftUI

    /// This view renders a collection of ``DeckItem`` values as
    /// a physical deck of cards.
    ///
    /// This view lets users swipe the top card in any direction
    /// to move it to the bottom of the deck and trigger actions.
    ///
    /// You can use the ``SwiftUI/View/deckViewConfiguration(_:)``
    /// view modifier to apply a custom configuration.
    public struct DeckView2<ItemType: DeckItem, ItemView: View>: View {
        /// Create a deck view with custom parameters.
        ///
        /// - Parameters:
        ///   - items: The items to present.
        ///   - config: The configuration to apply, by default `.standard`.
        ///   - shuffleAnimation: The shuffle animation to apply, by default an internal one.
        ///   - swipeLeftAction: The action to trigger when swiping items left, by default `nil`.
        ///   - swipeRightAction: The action to trigger when swiping items right, by default `nil`.
        ///   - swipeUpAction: The action to trigger when swiping items up, by default `nil`.
        ///   - swipeDownAction: The action to trigger when swiping items down, by default `nil`.
        ///   - itemView: An item view builder to use for each item in the deck.
        public init(
            shuffleAnimation: DeckShuffleAnimation = .init(),
            deckController: DeckController<ItemType>,
            swipeLeftAction: ItemAction? = nil,
            swipeRightAction: ItemAction? = nil,
            swipeUpAction: ItemAction? = nil,
            swipeDownAction: ItemAction? = nil,
            itemView: @escaping ItemViewBuilder
        ) {
            initConfig = nil
            _shuffleAnimation = .init(wrappedValue: shuffleAnimation)
            self.deckController = deckController
            self.swipeLeftAction = swipeLeftAction
            self.swipeRightAction = swipeRightAction
            self.swipeUpAction = swipeUpAction
            self.swipeDownAction = swipeDownAction
            self.itemView = itemView
        }

        /// A function to trigger when swiping away a deck item.
        public typealias ItemAction = (ItemType) -> Void

        /// A function that creates a view for a deck item.
        public typealias ItemViewBuilder = (ItemType) -> ItemView

        private var initConfig: DeckViewConfiguration?
        private let itemView: (ItemType) -> ItemView
        private let swipeLeftAction: ItemAction?
        private let swipeRightAction: ItemAction?
        private let swipeUpAction: ItemAction?
        private let swipeDownAction: ItemAction?

        @Environment(\.deckViewConfiguration)
        private var envConfig: DeckViewConfiguration

        @ObservedObject
        private var shuffleAnimation: DeckShuffleAnimation

        @ObservedObject
        private var deckController: DeckController<ItemType>

//        @Binding
//        private var items: [ItemType]
//
//        @State
//        private var activeItem: ItemType?
//
//        @State
//        private var topItemOffset: CGSize = .zero

        public var body: some View {
            ZStack(alignment: .center) {
                ForEach(visibleItems) { item in
                    itemView(item)
                        .zIndex(zIndex(of: item))
                        .shadow(color: Color.black.opacity(0.1), radius: 0, y: 1)
                        .offset(size: dragOffset(for: item))
                        .scaleEffect(scale(of: item))
                        .offset(y: offset(of: item))
                        .rotationEffect(dragRotation(for: item) ?? .zero)
//                        .gesture(dragGesture(for: item))
                        .deckShuffleAnimation(
                            shuffleAnimation,
                            for: item,
                            in: deckController.items
                        )
                }
            }
        }
    }

    // MARK: - Properties

    private extension DeckView2 {
        var config: DeckViewConfiguration {
            initConfig ?? envConfig
        }

        var visibleItems: [ItemType] {
            let first = Array(deckController.items.prefix(config.itemDisplayCount))
            guard
                config.alwaysShowLastItem,
                let last = deckController.items.last,
                !first.contains(last)
            else { return first }
            return Array(first).dropLast() + [last]
        }
    }

    // MARK: - View Logic

    private extension DeckView2 {
        func dragGesture(for item: ItemType) -> some Gesture {
            DragGesture()
                .onChanged { dragGestureChanged($0, for: item) }
                .onEnded { dragGestureEnded($0) }
        }

        func dragGestureChanged(_ drag: DragGesture.Value, for item: ItemType) {
            if deckController.activeItem == nil { deckController.activeItem = item }
            if item != deckController.activeItem { return }
            deckController.topItemOffset = drag.translation
            withAnimation(.spring()) {
                if dragGestureIsPastThreshold(drag) {
                    deckController.items.moveToBack(item)
                } else {
                    deckController.items.moveToFront(item)
                }
            }
        }

        func dragGestureEnded(_ drag: DragGesture.Value) {
            if let item = deckController.activeItem {
                dragGestureEndedAction(for: drag)?(item)
            }
            withAnimation(.spring()) {
                deckController.activeItem = nil
                deckController.topItemOffset = .zero
            }
        }

        func dragGestureEndedAction(for drag: DragGesture.Value) -> ItemAction? {
            guard dragGestureIsPastThreshold(drag) else { return nil }
            if dragGestureIsPastHorizontalThreshold(drag) {
                return drag.translation.width > 0 ? swipeRightAction : swipeLeftAction
            } else {
                return drag.translation.height > 0 ? swipeDownAction : swipeUpAction
            }
        }

        func dragGestureIsPastThreshold(_ drag: DragGesture.Value) -> Bool {
            dragGestureIsPastHorizontalThreshold(drag) || dragGestureIsPastVerticalThreshold(drag)
        }

        func dragGestureIsPastHorizontalThreshold(_ drag: DragGesture.Value) -> Bool {
            abs(drag.translation.width) > config.horizontalDragThreshold
        }

        func dragGestureIsPastVerticalThreshold(_ drag: DragGesture.Value) -> Bool {
            abs(drag.translation.height) > config.verticalDragThreshold
        }

        func dragOffset(for item: ItemType) -> CGSize {
            isActive(item) ? deckController.topItemOffset : .zero
        }

        func dragRotation(for item: ItemType) -> Angle? {
            guard isActive(item) else { return nil }
            return .degrees(Double(deckController.topItemOffset.width) * config.dragRotationFactor)
        }

        func isActive(_ item: ItemType) -> Bool {
            item == deckController.activeItem
        }

        func offset(at index: Int) -> Double {
            if shuffleAnimation.isShuffling { return 0 }

            let offset = Double(index) * config.verticalOffset
            let multiplier: Double = config.direction == .down ? 1 : -1
            return offset * multiplier
        }

        func offset(of item: ItemType) -> Double {
            guard let index = visibleIndex(of: item) else { return .zero }
            return offset(at: index)
        }

        func scale(at index: Int) -> Double {
            let offset = Double(index) * config.scaleOffset
            return Double(1 - offset)
        }

        func scale(of item: ItemType) -> Double {
            guard let index = visibleIndex(of: item) else { return 1 }
            return scale(at: index)
        }

        func visibleIndex(of item: ItemType) -> Int? {
            visibleItems.firstIndex(of: item)
        }

        func zIndex(of index: ItemType) -> Double {
            guard let index = visibleIndex(of: index) else { return 0 }
            return Double(visibleItems.count - index)
        }
    }

    // MARK: - Private View Extensions

    private extension View {
        func offset(size: CGSize) -> some View {
            offset(x: size.width, y: size.height)
        }

        func scaleEffect(_ all: CGFloat) -> some View {
            scaleEffect(x: all, y: all)
        }
    }

    // MARK: - Preview

    private func item(
        _ index: Int
    ) -> PreviewCard.Item {
        .init(
            title: "Title \(index)",
            text: "Text \(index)",
            footnote: "Footnote \(index)",
            backgroundColor: .gray.opacity(0.1),
            tintColor: .black
        )
    }

    #Preview {
        @MainActor
        struct Preview: View {
            @StateObject
            var shuffle = DeckShuffleAnimation(animation: .snappy)

            @StateObject
            var deckController = DeckController(items: (0 ... 10).enumerated().map {
                item($0.offset)
            }, flipOffset: .init(width: 300, height: -150))

            var body: some View {
                VStack(spacing: 70) {
                    DeckView2(
                        shuffleAnimation: shuffle,
                        deckController: deckController,
                        swipeLeftAction: { _ in print("Left") },
                        swipeRightAction: { _ in print("Right") },
                        swipeUpAction: { _ in print("Up") },
                        swipeDownAction: { _ in print("Down") },
                        itemView: { item in
                            Card(
                                isFlipped: shuffle.isShuffling,
                                front: { PreviewCard(item: item) },
                                back: { Color.blue }
                            )
                            .shadow(radius: 1)
                            .aspectRatio(0.65, contentMode: .fit)
                        }
                    )

                    HStack {
                        Button("换一个") {
                            deckController.flip()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Shuffle") {
                            shuffle.shuffle($deckController.items)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }

        return Preview()
    }
#endif

public class DeckController<ItemType: DeckItem>: ObservableObject {
    public let allItems: [ItemType]

    @Published public var items: [ItemType]
    @Published public var activeItem: ItemType?
    @Published public var topItemOffset: CGSize = .zero

    @Published public var isFlipping = false // 新增：用于跟踪翻牌状态

    private var flipOffset: CGSize

    public init(items: [ItemType], flipOffset: CGSize) {
        allItems = items
        self.items = items
        self.flipOffset = flipOffset
    }

    public func flip() {
        guard items.count > 1, !isFlipping else { return }

        isFlipping = true

        activeItem = items.first

        if #available(iOS 17.0, *) {
            withAnimation(.easeOut(duration: 0.3)) {
                topItemOffset = CGSize(width: 380, height: -250)
            } completion: {
                withAnimation {
                    self.items.removeFirst()
                }
                self.activeItem = nil
                self.topItemOffset = .zero
                self.isFlipping = false
            }
        } else {
            // 为旧版iOS提供后备方案
            items.removeFirst()
            activeItem = nil
        }
    }
}

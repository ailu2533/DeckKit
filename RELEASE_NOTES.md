# Release notes

DeckKit will use semver after 1.0. 

Until then, deprecated features may be removed in the next minor version.



## 0.7.1

### 💡 New features

* `Deck` has new `move` functions.



## 0.7

### 💡 New features

* `Deck` has a new `shuffle` function.
* `DeckShuffleAnimation` is a new animation.
* `DeckView` has a new convenience initializer.



## 0.6

### 💡 New features

This version adds an additional `DeckView` initializer so that you don't have to specify the `itemViewBuilder` parameter name.

### 💥 Breaking Changes

* All previously deprecated code has been removed.
* `DeckView` `itemViewBuilder` has been renamed to `itemView`.



## 0.5

### 💡 Behavior changes

* `DeckView` action parameters are now optional.
* `DeckView` card builder no longer requires `AnyView`.

### 🗑️ Deprecations

* `BasicCard` has been deprecated and will be removed in 0.6.
* `HorizontalDeck` has been deprecated and will be removed in 0.6.
* `StackedDeck` has been renamed to `DeckView`.
* `StackedDeck` has a new `itemViewBuilder` initializer.
* `StackedDeckConfiguration` has been renamed to `DeckViewConfiguration`.
* `StackedDeckConfiguration` has a new `itemDisplayCount` initializer.

### 💥 Breaking Changes

* `BasicCard` no longer applies a fixed width to its content.
* `HorizontalDeck` no longer contains a scroll view.



## 0.4

### ✨ New features

* `StackedDeck` uses a new `StackedDeckConfiguration`.
* `StackedDeckConfiguration` has a `.standard` value that is automatically used.

### 💡 Behavior changes

* `StackedDeck` no longer changes the card offset value within an animation.

### 💥 Breaking Changes

* `StackedDeck` now takes a configuration as init parameter instead of separate values.



## 0.3

### ✨ New features

* `Deck` now lets you specify id.

### 💥 Breaking Changes

* `BasicItem` has been renamed to `BasicCard.Item`.
* `CardItem` has been renamed to `DeckItem`.



## 0.2

The `deck` init params for `StackedDeck` and `HorizontalDeck` has been changed to a binding.

This gives you better control over the deck, removes UI glitches and helped me remove a bunch of state for visible cards in `StackDeck`, which means that deck modifications now instantly trigger UI changes. 

I have added a shuffle button to the demo to demonstrate how much better the stacked deck performs.

The `StackedDeck` has been improved in more ways:

* I have changed the order of how the vertical offset and scale effect are applied, which fixes a UI glitch.
* I have added `swipeLeft/Right/Up/Down` actions which let you trigger actions depending on how a user swipes a card of the top of the deck.

The `DeckContext` class is still in the library, but is not used by the library itself.



## 0.1.1

This version was just made to force the CocoaPod to pass validation. 



## 0.1

This version is the first public release of DeckKit. 

It contains components that are used in apps that have been pushed to production, which is why I decided to release it as a first minor.

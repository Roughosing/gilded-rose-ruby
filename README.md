*A practice refactoring of the Gilded Rose kata, with the steps written down along the way.*

[![Ruby](https://img.shields.io/badge/ruby-3.3-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Tests](https://github.com/Roughosing/gilded-rose-ruby/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/Roughosing/gilded-rose-ruby/actions/workflows/tests.yml)

# Gilded Rose Requirements Specification

Hi and welcome to team Gilded Rose. As you know, we are a small inn with a prime location in a
prominent city ran by a friendly innkeeper named Allison. We also buy and sell only the finest goods.
Unfortunately, our goods are constantly degrading in `Quality` as they approach their sell by date.

We have a system in place that updates our inventory for us. It was developed by a no-nonsense type named
Leeroy, who has moved on to new adventures. Your task is to add the new feature to our system so that
we can begin selling a new category of items. First an introduction to our system:

- All `items` have a `SellIn` value which denotes the number of days we have to sell the `items`
- All `items` have a `Quality` value which denotes how valuable the item is
- At the end of each day our system lowers both values for every item

Pretty simple, right? Well this is where it gets interesting:

- Once the sell by date has passed, `Quality` degrades twice as fast
- The `Quality` of an item is never negative
- **"Aged Brie"** actually increases in `Quality` the older it gets
- The `Quality` of an item is never more than `50`
- **"Sulfuras"**, being a legendary item, never has to be sold or decreases in `Quality`
- **"Backstage passes"**, like aged brie, increases in `Quality` as its `SellIn` value approaches;
  - `Quality` increases by `2` when there are `10` days or less and by `3` when there are `5` days or less but
  - `Quality` drops to `0` after the concert

We have recently signed a supplier of conjured items. This requires an update to our system:

- **"Conjured"** items degrade in `Quality` twice as fast as normal items

Feel free to make any changes to the `UpdateQuality` method and add any new code as long as everything
still works correctly. However, do not alter the `Item` class or `Items` property as those belong to the
goblin in the corner who will insta-rage and one-shot you as he doesn't believe in shared code
ownership (you can make the `UpdateQuality` method and `Items` property static if you like, we'll cover
for you).

Just for clarification, an item can never have its `Quality` increase above `50`, however **"Sulfuras"** is a
legendary item and as such its `Quality` is `80` and it never alters.

## My Approach

The first thing to identify with the solution are the code smells. These are the obvious issues that cause confusion, complication, complexity, and will eventually end up as technical debt if you leave them alone. Surprisingly, for the items listed above, the original method worked, the tests all passed green. The pain shows up when you want to add a new type of item with its own rules. As Kent Beck says, make the change easy, then make the easy change.

1. [Lock the current behaviour](#1-lock-the-current-behaviour)
2. [Name the code smells](#2-name-the-code-smells)
3. [Extract a method per item](#3-extract-a-method-per-item)
4. [Keep](#4-keep-item-as-the-inventory-record) `Item` [as the inventory record](#4-keep-item-as-the-inventory-record)
5. [Move each rule into a handler](#5-move-each-rule-into-a-handler)
6. [Choose the handler with a factory](#6-choose-the-handler-with-a-factory)
7. [What](#7-what-gildedrose-looks-like-now) `GildedRose` [looks like now](#7-what-gildedrose-looks-like-now)
8. [Where the classes live](#8-where-the-classes-live)
9. [Add Conjured](#9-add-conjured)



### 1. Lock the current behaviour

Before I moved any logic, I needed tests that proved the code already worked. The kata gives you a fully functional mess and basically nothing to tell you it works. So I added a test suite first. I took the test suite from Sandi Metz' 2014 RailsConf implementation of the kata, and to my surprise the tests all passed. I added to the tests because I wanted to make sure that at each pass we were maintaining all existing behaviour.

I ran that suite after every change. If a number changed and a test failed, I'd changed behaviour, and that wasn't the point of this pass.

### 2. Name the code smells

After adding the tests, it's time to start refactoring. Firstly, let's identify the code smells. I've listed the ones that are immediately apparent after first looking at `update_quality`:

- Long Method
- Duplicate Code
- Nested Conditionals
- Confusing Logic
- Magic Numbers
- Magic Strings
- Repeated Checks
- Primitive Obsession
- Feature Envy

The first and most obviously glaring one is the long, complicated method. Nested conditionals, confusing logic, repeated code, magic numbers and strings, and multiple and repeated calls to item. This single method was handling all of the quality degrading and increasing for every item. That breaks the single responsibility principle, the open/closed principle, and DRY.

To get out of that, I used:

- Extract Method
- Extract Class
- Extract Constant
- Extract Method Object (which is what `ItemUpdater` ends up being)



### 3. Extract a method per item

For the first pass, I extracted the logic for each item into its own method. Structure changes, behaviour doesn't. This way the tests should still pass.

A normal item loses quality, and it loses a second point once `sell_in` has gone negative. Aged Brie is the one that goes up. Don't mix those two up, I did at one point and the suite hated it.

```ruby
def update_normal_item(item)
  item.sell_in -= 1
  return if item.quality <= 0

  item.quality -= 1
  item.quality -= 1 if item.sell_in < 0 && item.quality > 0
end

def update_aged_brie(item)
  item.sell_in -= 1
  return if item.quality >= 50

  item.quality += 1
  item.quality += 1 if item.sell_in < 0 && item.quality < 50
end

def update_backstage_passes(item)
  item.sell_in -= 1
  return item.quality = 0 if item.sell_in < 0
  return if item.quality >= 50

  item.quality += 1
  item.quality += 1 if item.sell_in < 10
  item.quality += 1 if item.sell_in < 5
end
```

Immediately it becomes easier to see how each item handles its own quality update. Backstage passes are the awkward one. The increases stack, so inside 10 days you add a second point, and inside 5 days you add a third. An `if` / `elsif` chain won't do that on its own. This version can also walk past 50. The early return only skips the update when quality is already 50, so a pass at 49 with five days left becomes 52. The cap tests fail on this snippet. `increase_quality`, added later, is what stops a step from crossing 50. The shape is clearer, and then the tests go back to green.

But we still have update how we select what item method to use, let's start with a case statement:

```ruby
def update_item(item)
  case item.name
  when "Aged Brie"
    update_aged_brie(item)
  when "Backstage passes to a TAFKAL80ETC concert"
    update_backstage_passes(item)
  when "Sulfuras, Hand of Ragnaros"
    update_sulfuras(item)
  else
    update_normal_item(item)
  end
end
```

This doesn't look so bad now, but we still have some magic strings, numbers, primitive obsession, feature envy, and duplicated code lingering about. And it all still lives in `GildedRose`, so there's a lot of responsibility in this one class. Add another custom item and the case statement starts to bloat. That's the next difficult change, which is exactly what we don't want.

### 4. Keep `Item` as the inventory record

To combat the bloated case statement, look at the items and how they actually behave. They don't change. Each special item has its own fixed behaviour, and you can identify it by name. Unless of course it's a normal item, in which case we just default anything we haven't named. So what we do here is turn this into an OOP refactor, and extract those rules into their own classes:

```ruby
class AgedBrieUpdater
end

class BackstagePassesUpdater
end

class SulfurasUpdater
end

class NormalItemUpdater
end
```

Right now, you might be thinking the best way forward is to make all of these a subclass of `Item`, so we could initialise an Aged Brie as `AgedBrieUpdater.new(sell_in: x, quality: 5)`. That isn't a bad first thought, but it would be a behavioural change. Our tests instantiate items like `Item.new('Aged Brie', 3, 10)`, then read `sell_in` and `quality` back off that same object. `AgedBrieUpdater.new` is a different object. Update the copy and the original `Item` just sits there, and the suite goes red. The goblin in the requirements also doesn't want us altering `Item`. It stays the record: `name`, `sell_in`, `quality`, and `to_s`.

We're focussed on structural changes for this pass. So we extract the behaviour into the new classes, create one object for the common update logic, and use the Factory Pattern to build the handlers. The handler wraps the `Item` we already have and updates that.

### 5. Move each rule into a handler

The methods above still repeat themselves, and they still reach into `item` for every tweak. Pull those lines out before the classes show up.

Using extract method on the line every item shares:

`item.sell_in -= 1` -> `decrease_sell_in`

The quality updates are the same extract. That gathers the repeated `item.quality` tweaks into one place. It does not clear feature envy. Backstage passes still read `@item.sell_in` to choose a band, and they still write `@item.quality` when the concert is over. The handler asks for the operation:

`item.quality -= 1` -> `decrease_quality`

`item.quality += 1` -> `increase_quality`

`item.sell_in < 0` -> `expired?`

What is left are the raw numbers. The ones worth naming are the domain rules: the cap at `50`, the floor at `0`, the 10-day and 5-day bands, and degrading twice as fast. A constant for every `1` does not explain anything. The item is still a name string and two integers, and the factory still matches on those strings, so the magic names are smaller, not gone.

`50` -> `QUALITY_MAX`

`0` -> `QUALITY_MIN`

`10` -> `SELL_IN_10_DAYS`

`2` -> `QUALITY_DECREMENT_ON_EXPIRATION`

Now we'll start to have something like this. `increase_quality` returns when quality is already `50` or higher, so an increase never walks past the cap and never pulls a value above `50` down to it. `decrease_quality` only stops at `0`, so a normal item already above `50` still loses quality. Sulfuras stays at `80` because `SulfurasUpdater#update_item` does nothing. `ItemUpdater#update_item` raises `NotImplementedError`, so a new handler cannot inherit that silence by accident.

So the handlers look like this:

```ruby
class AgedBrieUpdater < ItemUpdater
  def update_item
    decrease_sell_in
    increase_quality(quality_increase_step)
  end

  private

  def quality_increase_step
    expired? ? 2 : 1
  end
end

class BackstagePassesUpdater < ItemUpdater
  SELL_IN_5_DAYS = 5
  SELL_IN_10_DAYS = 10
  QUALITY_INCREMENT_ON_5_DAYS = 3
  QUALITY_INCREMENT_ON_10_DAYS = 2

  def update_item
    decrease_sell_in
    return set_quality_to_zero if expired?
    return increase_quality(QUALITY_INCREMENT_ON_5_DAYS) if @item.sell_in < SELL_IN_5_DAYS
    return increase_quality(QUALITY_INCREMENT_ON_10_DAYS) if @item.sell_in < SELL_IN_10_DAYS

    increase_quality
  end

  private

  def set_quality_to_zero
    @item.quality = QUALITY_MIN
  end
end

class SulfurasUpdater < ItemUpdater
  def update_item
  end
end

class NormalItemUpdater < ItemUpdater
  QUALITY_DECREMENT_ON_EXPIRATION = 2

  def update_item
    decrease_sell_in
    return decrease_quality(QUALITY_DECREMENT_ON_EXPIRATION) if expired?

    decrease_quality
  end
end
```

And then `ItemUpdater`, which the above inherit from, and where the shared operations live looks like this:

```ruby
class ItemUpdater
  QUALITY_MAX = 50
  QUALITY_MIN = 0

  def initialize(item)
    @item = item
  end

  def update_item
    raise NotImplementedError, "#{self.class} must implement update_item"
  end

  private

  def decrease_sell_in
    @item.sell_in -= 1
  end

  def increase_quality(step = 1)
    return if @item.quality >= QUALITY_MAX

    @item.quality = [@item.quality + step, QUALITY_MAX].min
  end

  def decrease_quality(step = 1)
    return if @item.quality <= QUALITY_MIN

    @item.quality = [@item.quality - step, QUALITY_MIN].max
  end

  def expired?
    @item.sell_in < 0
  end
end
```

`initialize` keeps the `Item` that already exists. Every helper below changes that same object, which is why the tests can read `sell_in` and `quality` back off the original record.

The early return in `increase_quality` matters. It leaves a quality that is already past `50` untouched, then the `min` / `max` stop a larger step from walking through the bound. Quality `49` with five days left becomes `50`, not `54`. An expired normal item at quality `1` becomes `0`, not `-1`. The per-point checks in the first extract were doing that job. The helper does it now, so a day's change can be one number.

These handlers all respond to `update_item`. That is the polymorphism. The shared helpers are where the cap and the floor live, so those checks are not copied into every handler. Each handler still owns its own rule, and backstage passes still touch `@item` for the sell-in bands and the post-concert reset.

A new custom item is a new class. `GildedRose` doesn't grow another branch for it. The factory below still needs to learn the new name, and that's the one place you edit.

### 6. Choose the handler with a factory

Next we need to manage how these handlers get chosen. `ItemUpdaterFactory` does just that. Worth saying what it isn't: it is not building an `Item`. The `Item` already exists. `build` picks a handler and wraps that item.

```ruby
class ItemUpdaterFactory
  UPDATER_CLASSES = {
    "Aged Brie" => AgedBrieUpdater,
    "Backstage passes to a TAFKAL80ETC concert" => BackstagePassesUpdater,
    "Sulfuras, Hand of Ragnaros" => SulfurasUpdater
  }.freeze

  def self.build(item)
    UPDATER_CLASSES.fetch(item.name, NormalItemUpdater).new(item)
  end
end
```

Here we have a constant whose values are the handler classes. `fetch` selects the class; `.new(item)` builds the handler. Adding another custom item is one line in `UPDATER_CLASSES`, plus its `update_item`. Anything we don't recognise stays a `NormalItemUpdater`. This makes the change easy, so we can make the easy change.

### 7. What `GildedRose` looks like now

After all of that, the logic lives on the handler that actually owns it, and `GildedRose` looks like this:

```ruby
class GildedRose
  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      ItemUpdaterFactory.build(item).update_item
    end
  end
end
```

And the best part of all, the tests still pass. We've ended up with a little application that's far more streamlined, easier to manage, easier to understand, and easier to extend.

### 8. Where the classes live

If you want a more detailed breakdown of the new class structure after all of our refactorings, have a look at the map below:

```
ruby/
  gilded_rose.rb                      GildedRose
  item/
    item.rb                           Item
  updaters/
    item_updater_factory.rb           ItemUpdaterFactory
    item_updater.rb                   ItemUpdater
    normal_item_updater.rb            NormalItemUpdater
    conjured_updater.rb               ConjuredUpdater
    aged_brie_updater.rb              AgedBrieUpdater
    backstage_passes_updater.rb       BackstagePassesUpdater
    sulfuras_updater.rb               SulfurasUpdater
```

`GildedRose` is still the entry point. It keeps the `Item` records and asks `ItemUpdaterFactory` for a handler. The factory wraps the existing `Item` in `AgedBrieUpdater`, `BackstagePassesUpdater`, `SulfurasUpdater`, `ConjuredUpdater`, or `NormalItemUpdater`. Those handlers inherit `ItemUpdater`, which holds the shared sell-in and quality steps. Each handler's `update_item` changes the `Item` it was given.

```
GildedRose#update_quality
  └── ItemUpdaterFactory.build(item)
        ├── "Aged Brie"                                  → AgedBrieUpdater
        ├── "Backstage passes to a TAFKAL80ETC concert"  → BackstagePassesUpdater
        ├── "Sulfuras, Hand of Ragnaros"                 → SulfurasUpdater
        ├── "Conjured *"                                 → ConjuredUpdater
        └── any other name                               → NormalItemUpdater
              └── each is an ItemUpdater, wrapping the original Item
```



### 9. Add Conjured

This is the easy change the whole refactor was setting up. Adding a Conjured item used to mean another nest of conditionals inside `update_quality`. Now it's a new handler, and one change where `fetch` falls through. This took about 2 mins to do, and so should every new additional item, instead of countless hours trying to figure out where new conditional logic for an item should exist in the old approach.

The conjured items degrade twice as fast as a normal item, 2 before the sell date and 4 after it, and `GildedRose` doesn't have to know that.

```ruby
class ConjuredUpdater < ItemUpdater
  QUALITY_DECREMENT = 2
  QUALITY_DECREMENT_ON_EXPIRATION = 4

  def update_item
    decrease_sell_in
    return decrease_quality(QUALITY_DECREMENT_ON_EXPIRATION) if expired?

    decrease_quality(QUALITY_DECREMENT)
  end
end
```

In the factory, the hash of item names stays as it was. The new part is the `fetch` default. A missing name that starts with `"Conjured"` uses the handler above, so `"Conjured Mana Cake"` and `"Conjured Dark Blade"` both degrade twice as fast. Anything else is still a `NormalItemUpdater`.

```ruby
CONJURED_PREFIX = "Conjured"

def self.build(item)
  UPDATER_CLASSES.fetch(item.name) {
    item.name.start_with?(CONJURED_PREFIX) ? ConjuredUpdater : NormalItemUpdater
  }.new(item)
end
```

The tests pass, and `GildedRose` stays as it was. The name string is still how an item picks its rule. Exact names stay in the hash. Conjured is the prefix, because the requirement covers the whole category. The new class lives at `updaters/conjured_updater.rb`.
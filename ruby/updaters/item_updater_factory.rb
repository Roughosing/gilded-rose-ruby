class ItemUpdaterFactory
  ITEM_UPDATER_NAMES = {
    "Aged Brie" => AgedBrie,
    "Backstage passes to a TAFKAL80ETC concert" => BackstagePasses,
    "Sulfuras, Hand of Ragnaros" => Sulfuras
  }.freeze

  CONJURED_PREFIX = "Conjured"

  def self.build(item)
    ITEM_UPDATER_NAMES.fetch(item.name) {
      item.name.start_with?(CONJURED_PREFIX) ? Conjured : NormalItem
    }.new(item)
  end
end

class ItemUpdaterFactory
  ITEM_UPDATER_NAMES = {
    "Aged Brie" => AgedBrieUpdater,
    "Backstage passes to a TAFKAL80ETC concert" => BackstagePassesUpdater,
    "Sulfuras, Hand of Ragnaros" => SulfurasUpdater
  }.freeze

  CONJURED_PREFIX = "Conjured"

  def self.build(item)
    ITEM_UPDATER_NAMES.fetch(item.name) {
      item.name.start_with?(CONJURED_PREFIX) ? ConjuredUpdater : NormalItemUpdater
    }.new(item)
  end
end

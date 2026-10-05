require 'rspec'

require_relative '../gilded_rose'

# Same cases as Sandi Metz's RailsConf 2014 suite:
# https://gist.github.com/skmetz/7772668
describe GildedRose do
  def update_quality(items)
    GildedRose.new(items).update_quality
  end

  def update_quality_for_item_with(sell_in, quality, name = 'normal item')
    item = Item.new(name, sell_in, quality)
    update_quality([item])
    item
  end

  it 'normal item before sell date' do
    item = update_quality_for_item_with(5, 10, 'normal')
    expect(item.quality).to eq 9
    expect(item.sell_in).to eq 4
  end

  it 'normal item on sell date' do
    item = update_quality_for_item_with(0, 10, 'normal')
    expect(item.quality).to eq 8
    expect(item.sell_in).to eq(-1)
  end

  it 'normal item after sell date' do
    item = update_quality_for_item_with(-10, 10, 'normal')
    expect(item.quality).to eq 8
    expect(item.sell_in).to eq(-11)
  end

  it 'normal item of zero quality' do
    item = update_quality_for_item_with(5, 0, 'normal')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq 4
  end

  it 'normal item on sell date with quality one' do
    item = update_quality_for_item_with(0, 1, 'normal')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq(-1)
  end

  it 'brie before sell date' do
    item = update_quality_for_item_with(5, 10, 'Aged Brie')
    expect(item.quality).to eq 11
    expect(item.sell_in).to eq 4
  end

  it 'brie before sell date with max quality' do
    item = update_quality_for_item_with(5, 50, 'Aged Brie')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq 4
  end

  it 'brie on sell date' do
    item = update_quality_for_item_with(0, 10, 'Aged Brie')
    expect(item.quality).to eq 12
    expect(item.sell_in).to eq(-1)
  end

  it 'brie on sell date near max quality' do
    item = update_quality_for_item_with(0, 49, 'Aged Brie')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq(-1)
  end

  it 'brie after sell date' do
    item = update_quality_for_item_with(-10, 10, 'Aged Brie')
    expect(item.quality).to eq 12
    expect(item.sell_in).to eq(-11)
  end

  it 'brie after sell date with max quality' do
    item = update_quality_for_item_with(-10, 50, 'Aged Brie')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq(-11)
  end

  it 'sulfuras before sell date' do
    item = update_quality_for_item_with(5, 80, 'Sulfuras, Hand of Ragnaros')
    expect(item.quality).to eq 80
    expect(item.sell_in).to eq 5
  end

  it 'sulfuras on sell date' do
    item = update_quality_for_item_with(0, 80, 'Sulfuras, Hand of Ragnaros')
    expect(item.quality).to eq 80
    expect(item.sell_in).to eq 0
  end

  it 'sulfuras after sell date' do
    item = update_quality_for_item_with(-10, 80, 'Sulfuras, Hand of Ragnaros')
    expect(item.quality).to eq 80
    expect(item.sell_in).to eq(-10)
  end

  it 'backstage pass long before sell date' do
    item = update_quality_for_item_with(11, 10, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 11
    expect(item.sell_in).to eq 10
  end

  it 'backstage pass medium close to sell date upper bound' do
    item = update_quality_for_item_with(10, 10, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 12
    expect(item.sell_in).to eq 9
  end

  it 'backstage pass medium close to sell date upper bound at max quality' do
    item = update_quality_for_item_with(10, 50, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq 9
  end

  it 'backstage pass medium close to sell date upper bound near max quality' do
    item = update_quality_for_item_with(10, 49, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq 9
  end

  it 'backstage pass medium close to sell date lower bound' do
    item = update_quality_for_item_with(6, 10, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 12
    expect(item.sell_in).to eq 5
  end

  it 'backstage pass medium close to sell date lower bound at max quality' do
    item = update_quality_for_item_with(6, 50, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq 5
  end

  it 'backstage pass very close to sell date upper bound' do
    item = update_quality_for_item_with(5, 10, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 13
    expect(item.sell_in).to eq 4
  end

  it 'backstage pass very close to sell date upper bound at max quality' do
    item = update_quality_for_item_with(5, 50, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq 4
  end

  it 'backstage pass very close to sell date upper bound near max quality' do
    item = update_quality_for_item_with(5, 49, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq 4
  end

  it 'backstage pass very close to sell date lower bound' do
    item = update_quality_for_item_with(1, 10, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 13
    expect(item.sell_in).to eq 0
  end

  it 'backstage pass very close to sell date lower bound at max quality' do
    item = update_quality_for_item_with(1, 50, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 50
    expect(item.sell_in).to eq 0
  end

  it 'backstage pass on sell date' do
    item = update_quality_for_item_with(0, 10, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq(-1)
  end

  it 'backstage pass after sell date' do
    item = update_quality_for_item_with(-10, 10, 'Backstage passes to a TAFKAL80ETC concert')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq(-11)
  end

  it 'conjured item before sell date' do
    item = update_quality_for_item_with(5, 10, 'Conjured Mana Cake')
    expect(item.quality).to eq 8
    expect(item.sell_in).to eq 4
  end

  it 'another conjured item before sell date' do
    item = update_quality_for_item_with(5, 10, 'Conjured Dark Blade')
    expect(item.quality).to eq 8
    expect(item.sell_in).to eq 4
  end

  it 'conjured item at zero quality' do
    item = update_quality_for_item_with(5, 0, 'Conjured Mana Cake')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq 4
  end

  it 'conjured item before sell date with quality one' do
    item = update_quality_for_item_with(5, 1, 'Conjured Mana Cake')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq 4
  end

  it 'conjured item on sell date' do
    item = update_quality_for_item_with(0, 10, 'Conjured Mana Cake')
    expect(item.quality).to eq 6
    expect(item.sell_in).to eq(-1)
  end

  it 'conjured item on sell date at zero quality' do
    item = update_quality_for_item_with(0, 0, 'Conjured Mana Cake')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq(-1)
  end

  it 'conjured item on sell date with quality three' do
    item = update_quality_for_item_with(0, 3, 'Conjured Mana Cake')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq(-1)
  end

  it 'conjured item after sell date' do
    item = update_quality_for_item_with(-10, 10, 'Conjured Health Elixir')
    expect(item.quality).to eq 6
    expect(item.sell_in).to eq(-11)
  end

  it 'conjured item after sell date at zero quality' do
    item = update_quality_for_item_with(-10, 0, 'Conjured Sweet Roll')
    expect(item.quality).to eq 0
    expect(item.sell_in).to eq(-11)
  end

  it 'several items' do
    items = [
      Item.new('normal item', 5, 10),
      Item.new('Aged Brie', 3, 10)
    ]

    update_quality(items)
    expect(items[0].quality).to eq 9
    expect(items[0].sell_in).to eq 4
    expect(items[1].quality).to eq 11
    expect(items[1].sell_in).to eq 2
  end
end

module ProductHelper
  def tag_items_view(product)
    product.tags.map do |tag|
      %Q(<span class="tag">#{tag.name}</span>)
    end.join(' ')
  end
end

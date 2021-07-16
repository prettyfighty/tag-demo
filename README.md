# Tag with Select2

我的[部落格](https://lailai-blog.gq)：https://lailai-blog.gq

詳細步驟與說明，請參考[這篇文章](https://lailai-blog.gq/2021/07/16/Tag-With-Select2)

# Version

- Ruby 2.7.2

- Rails 6.1.4

# Install

1. $`bundle install`

2. $`yarn install`

3. $`rails db:migrate`

4. $`rails db:seed`

5. $`foreman s`

之後打開瀏覽器，輸入網址：**localhost:3000**

應該可以看到這個畫面，裡面有seed產生的20筆商品資料。

![](https://lailai-blog.gq/2021/07/16/Tag-With-Select2/02-product-list.jpg)

# Steps

## 新增標籤和商品的關聯

1. $`rails g model tag name`
新增一個叫做 Tag 的 model，並且有一個 name 欄位

2. $`rails g model tagging tag:belongs_to product:belongs_to`
新增一個叫做 Tagging 的 model，準備作為第三方關聯資料表來使用，因此加上 tag:belongs_to 和 product:belongs_to

3. $`rails db:migrate`
rails g model 的指令會產生對應的 migration 檔案，記得跑這個步驟才能建立資料表

4. 在 *app/models/tag.rb* 及 *app/models/product.rb* 新增關聯

```ruby
# app/models/tag.rb

class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :products, through: :taggings
end
```

```ruby
# app/models/product.rb

class Product < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  ...
end
```

### 基本款

5. 在 *_form.html.erb* 新增一個可以輸入標籤的input

```html
<!-- app/views/products/_form.html.erb -->

  ...
<%= simple_form_for(product) do |f| %>
  ...
  <%= f.input :tag_list, label: "標籤", input_html: {class: "form-control"} %>
  ...
<% end %>
```

6. 在 *products_controller.rb* 新增對應的 Strong Parameter

```ruby
# app/controllers/products_controller.rb

class ProductsController < ApplicationController
  ...
  def product_params
    params.require(:product).permit(:name, :description, :price, :tag_list)
  end
  ...
end
```

7. 在 Product 新增實體方法
除了新增商品時需要的 setter 之外，順便新增一個 getter 給它

```ruby
# app/models/product.rb

class Product < ApplicationRecord
  ...
  # 新增 setter
  def tag_list=(names)
    self.tags = names.split(',').map do |item|
      Tag.where(name: item.strip).first_or_create!
    end
  end

  # 新增 getter
  def tag_list
    tags.map(&:name).join(', ')
  end

end
```

8. 在 views 顯示出商品的標籤

```html
<!-- app/views/products/index.html.erb -->

    ...
        <th>品名</th>
    +   <th>標籤</th>
        <th>簡介</th>
    ...
          <td><%= link_to product.name, product_path(product), class: "text-decoration-none text-info fw-bold" %></td>
    +     <td><%= product.tag_list %></td>
          <td class="overflow-hidden w-solid textOverflow"><%= product.description %></td>
    ...
```

### 進階款: 使用 select2

9. $`yarn add select2`
安裝 select2

10. 修改 *products_controller.rb* 對應的 Strong Parameter

```ruby
# app/controllers/products_controller.rb

class ProductsController < ApplicationController
  ...
  def product_params
    params.require(:product).permit(:name, :description, :price, { tag_items: [] } )
  end
  ...
end
```

11. 修改 Product 的實體方法

```ruby
# app/models/product.rb

class Product < ApplicationRecord
  ...
  # 新增 setter (select2)
  def tag_items=(names)
    self.tags = names.map{|item|
    Tag.where(name: item.strip).first_or_create! unless item.blank?}.compact!
  end

  # 新增 getter (select2)
  def tag_items
    tags.map(&:name)
  end
end
```

12. 修改 view 顯示標籤的方法

```html
<!-- app/views/products/index.html.erb -->

    ...
          <td><%= link_to product.name, product_path(product), class: "text-decoration-none text-info fw-bold" %></td>
    +     <td><%= product.tag_items %></td>
          <td class="overflow-hidden w-solid textOverflow"><%= product.description %></td>
    ...
```

13. 在輸入表單套用 select2
這邊除了修改 view 之外，還需要增加一些 JavaScript

```html
<!-- app/views/products/_form.html.erb -->

  ...
<%= simple_form_for(product) do |f| %>
  ...
  <%= f.input :tag_items, collection: product.tag_items, label: "標籤", input_html: {multiple: true, class: "form-control js-tag-select"} %>
  ...
<% end %>
```

```js
// app/javascript/packs/application.js

  ...
// select2
import "select2"
import "select2/dist/css/select2.css"

document.addEventListener("turbolinks:load", () => {
  ...
  $(".js-tag-select").select2({
    tags: true,
    tokenSeparators: [',', ' ']
  })

})
```

14. 用 view helper 及 css 美化標籤

14-1. 新增 helper

```ruby
# app/helpers/product_helper.rb

module ProductHelper
  def tag_items_view(product)
    product.tags.map do |tag|
      %Q(<span class="tag">#{tag.name}</span>)
    end.join(' ')
  end
end
```

14-2. 修改 *app/views/products/index.html.erb*

```html
<!-- app/views/products/index.html.erb -->

    ...
          <td><%= link_to product.name, product_path(product), class: "text-decoration-none text-info fw-bold" %></td>
    -     <td><%= product.tag_items %></td>
    +     <td><%= tag_items_view(product).html_safe %></td>
          <td class="overflow-hidden w-solid textOverflow"><%= product.description %></td>
    ...
```

14-3. 新增 css

```scss
// app/javascript/styles/common.scss

...
.tag {
  display: inline-block;
  font-weight: 400;
  line-height: 1.5;
  color: #cca700;
  text-align: center;
  text-decoration: none;
  vertical-align: middle;
  background-color: transparent;
  border: 1px solid #cca700;
  padding: 0 0.75rem;
  font-size: 1rem;
  border-radius: 0.25rem;
}
```

完成圖

![](https://lailai-blog.gq/2021/07/16/Tag-With-Select2/08-select2-input.jpg)

![](https://lailai-blog.gq/2021/07/16/Tag-With-Select2/12-helper-css.jpg)

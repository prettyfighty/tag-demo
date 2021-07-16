class ProductsController < ApplicationController

  before_action :find_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.includes(:tags).order(created_at: :desc)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to root_path, notice: "新增商品成功"
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to root_path, notice: "修改商品成功"
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to root_path, notice: "刪除商品成功"
  end

  private
  def product_params
    params.require(:product).permit(:name, :description, :price, :tag_list)
  end

  def find_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, notice: "找不到資料"
  end
end

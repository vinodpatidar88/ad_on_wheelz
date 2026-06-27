class Admin::SubCategoriesController < Admin::BaseController
  before_action :set_sub_category, only: [:show, :edit, :update, :destroy]

  def index
    @sub_categories = SubCategory.all
  end

  def show
  end

  def new
    @sub_category = SubCategory.new
  end

  def edit
  end

  def create
    @sub_category = SubCategory.new(sub_category_params)
    if @sub_category.save
      redirect_to admin_sub_categories_path, notice: 'Sub category was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @sub_category.update(sub_category_params)
      redirect_to admin_sub_categories_path, notice: 'Sub category was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sub_category.destroy
    redirect_to admin_sub_categories_path, notice: 'Sub category was successfully destroyed.'
  end

  private

  def set_sub_category
    @sub_category = SubCategory.find(params[:id])
  end

  def sub_category_params
    params.require(:sub_category).permit(:category_id, :name, :description)
  end
end

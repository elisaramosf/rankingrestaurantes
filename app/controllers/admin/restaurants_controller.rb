class Admin::RestaurantsController < Admin::BaseController
  before_action :set_restaurant, only: %i[edit update destroy]

  def index
    @restaurants = Restaurant.includes(:category).order(:name)
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save
      redirect_to admin_restaurants_path, notice: "Restaurante creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @restaurant.update(restaurant_params)
      redirect_to admin_restaurants_path, notice: "Restaurante actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @restaurant.destroy
      redirect_to admin_restaurants_path, notice: "Restaurante eliminado.", status: :see_other
    else
      redirect_to admin_restaurants_path, alert: "No se pudo eliminar el restaurante.", status: :see_other
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def restaurant_params
    params.expect(restaurant: [ :name, :address, :category_id ])
  end
end
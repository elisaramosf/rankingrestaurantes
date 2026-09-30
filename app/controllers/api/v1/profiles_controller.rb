class Api::V1::ProfilesController < Api::V1::BaseController
  before_action :authenticate_user!

  def show
    render json: { id: current_user.id, name: current_user.name, email: current_user.email }
  end
end

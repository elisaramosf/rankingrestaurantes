class Api::V1::UsersController < Api::V1::BaseController
  def create
    user = User.new(params.permit(:name, :email, :password))

    if user.save
      UserMailer.welcome(user).deliver_now
      render json: { id: user.id, name: user.name, email: user.email }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end

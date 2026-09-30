class Api::V1::SessionsController < Api::V1::BaseController
  before_action :authenticate_user!, only: :destroy

  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])

    if user
      api_session = user.sessions.create!(ip_address: request.remote_ip, user_agent: request.user_agent)
      render json: { token: api_session.token, user: { id: user.id, name: user.name, email: user.email } },
             status: :created
    else
      render json: { error: "Email o contraseña inválidos" }, status: :unauthorized
    end
  end

  def destroy
    @current_session.destroy
    head :no_content
  end
end

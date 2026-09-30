class Api::V1::BaseController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "No encontrado" }, status: :not_found
  end

  private

  def authenticate_user!
    token = request.authorization.to_s.delete_prefix("Bearer ")
    @current_session = Session.find_by(token: token) if token.present?
    render json: { error: "No autorizado" }, status: :unauthorized unless @current_session
  end

  def current_user
    @current_session&.user
  end
end
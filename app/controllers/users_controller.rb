class UsersController < ApplicationController

  def auth
    # Parse OAuth hash
    auth_hash = request.env['omniauth.auth']

    # Find an existing user from this provider
    @user = User.where("provider = ? AND uid = ?", auth_hash.provider, auth_hash.uid.to_s).first
    # Try finding user by email address
    @user = User.find_by_email(auth_hash.info.email) unless @user
    unless @user
      # Create a new user
      @user = User.new(email: auth_hash.info.email, name: auth_hash.info.name)
      @user.provider = auth_hash.provider
      @user.uid = auth_hash.uid.to_s
      @user.save!
      @user.import_data(auth_hash.provider)
    end

    # save access token from this provider
    token = @user.tokens.where(provider: auth_hash.provider).first
    if token
      token.content = auth_hash.credentials.token
      token.save!
    else
      @user.tokens.create!(provider: auth_hash.provider, content: auth_hash.credentials.token)
    end

    session[:user_id] = @user.id

    # Render web app
    redirect_to dashboard_path
  end

  def logout
    reset_session

    redirect_to login_path
  end

  def authfail
    render :text => params[:message]
  end

  api :GET, '/users/:id', "Get a specific user"
  def show
    @user = User.find(params[:id])
    render json: @user, root: false
  end
end

class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:auth, :authfail]

  def auth
    # Parse OAuth hash
    auth_hash = request.env['omniauth.auth']
    new_user = false

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
      new_user = true
    end

    # save access token from this provider
    token = @user.tokens.find_or_initialize_by(provider: auth_hash.provider)
    token.content = auth_hash.credentials.token
    token.save!

    @user.import_data(auth_hash.provider) if new_user

    session[:user_id] = @user.id

    # Render web app
    flash.notice = 'Welcome to Found! We\'ve pulled in some of your data from AngelList to get you started.' if new_user
    redirect_to @user
  end

  api :GET, '/users/:id/logout', 'Destroy current session'
  def logout
    reset_session

    flash.notice = 'You have successfully logged out.'
    redirect_to root_path
  end

  def authfail
    flash.alert = params[:message]
    redirect_to root_path
  end

  api :GET, '/users/:id/import', 'Import data from a provider'
  param :provider, String, :required => true, :desc => 'Name of provider to import data from'
  def import
    current_user.import_data(params[:provider])

    head :ok
  end

  api :GET, '/users/:id', 'Get a specific user'
  def show
    @user = User.find(params[:id])
  end

  api :GET, '/users/search', 'Search for users'
  param :q, String, :required => false
  def search
    @users = User.search do
      fulltext params[:q] do
        query_phrase_slop 2
        phrase_slop 2
      end
    end.results if params[:q]
  end
end

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

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.name = params[:name] if params[:name]
    @user.bio = params[:bio] if params[:bio]
    @user.what_ive_built = params[:what_ive_built] if params[:what_ive_built]
    @user.what_i_do = params[:what_i_do] if params[:what_i_do]
    @user.save!

    flash.notice = 'Your profile was successfully updated.'
    redirect_to @user
  end

  api :GET, '/users/search', 'Search for users'
  param :q, String, :required => false, :desc => 'query to fulltext search keywords for'
  param :age, String, :required => false, :desc => 'approximate age of founder to search for'
  param :years, String, :required => false, :desc => 'number of years working on startups'
  param :startups, String, :required => false, :desc => 'number of startups worked on'
  param :size, String, :required => false, :desc => 'size of largest company: 1-10, 11-50, 51-200, 201-500, 500+'
  param :investor, ['true','false', ''], :required => false, :desc => 'is the founder also an investor?'
  param :funded, ['true','false', ''], :required => false, :desc => 'has this founder been funded?'
  def search
    @users = User.search do
      fulltext params[:q] do
        query_phrase_slop 2
        phrase_slop 2
      end

      # search age +- 20%
      with(:age, 0.8*params[:age].to_i..1.2*params[:age].to_i) unless params[:age].blank?
      # search number of years in startups +- 20%
      with(:total_startup_years, 0.8*params[:years].to_i..1.2*params[:years].to_i) unless params[:years].blank?
      # search total number of startups +- 1
      with(:startup_count, params[:startups].to_i - 1..params[:startups].to_i + 1) unless params[:startups].blank?
      with(:max_company_size, params[:size]) unless params[:size].blank?
      with(:investor, params[:investor] == 'true') unless params[:investor].blank?
      with(:funded, params[:funded] == 'true') unless params[:funded].blank?
    end.results
  end
end

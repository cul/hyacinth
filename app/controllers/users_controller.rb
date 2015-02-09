class UsersController < ApplicationController
  before_action :require_hyacinth_admin!, except: [:do_wind_login, :do_cas_login]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_contextual_nav_options

  # Note: To log a specific user in manually, use:
  # sign_in User.where(email: 'durst@library.columbia.edu').first, :bypass => true

  # GET /users/do_wind_login
  def do_wind_login

    wind_server_uri = 'https://wind.columbia.edu'
    wind_login_uri = wind_server_uri + '/login'
    wind_validate_uri = wind_server_uri + '/validate'
    wind_logout_uri = wind_server_uri + '/logout'
    wind_realm = 'ldpd_non_sso'

    if user_signed_in?
      redirect_to root_path
    end

    if ! params[:ticketid]

      # Login: Part 1

      # If ticketid is NOT set, this means that the user hasn't gotten to the uni/password login page yet.  Let's send them there.
      # After they log in, they'll be redirected to this page and they'll continue with the authentication.

      redirect_to(wind_login_uri + '?service=' + wind_realm + '&destination=' + URI::escape(request.original_url))

    else
      # Login: Part 2
      # If ticketid is set, we'll use that ticket for login part 2.

      #We'll validate the ticket against the wind server
      full_validate_uri = wind_validate_uri + '?sendxml=1&ticketid=' + params['ticketid']

      uri = URI.parse(full_validate_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env == 'development'

      wind_request = Net::HTTP::Get.new(uri.request_uri)
      response_body = http.request(wind_request).body

      user_uni = nil

      if(response_body.start_with?('<'))
        xml_response = Nokogiri::XML(response_body)
        xml_response.remove_namespaces!
        user_uni = xml_response.xpath('/serviceResponse/authenticationSuccess/user').first.text
      else
        if response_body.start_with?('yes')
          user_uni = response_body[3,response_body.length].strip
        end
      end

      if user_uni.present?

        possible_user = User.where(email: (user_uni + '@columbia.edu')).first

        unless possible_user.nil?
          sign_in possible_user, :bypass => true
          session[:signed_in_using_uni] = true # TODO use this session variable to know when to do a Wind logout upon Devise logout
          flash[:notice] = 'You are now logged in.'

          redirect_to root_path, :status => 302
        else
          flash[:notice] = 'The UNI ' + user_uni + ' is not authorized to log into Hyacinth (no account exists with email ' + user_uni + '@columbia.edu).  If you believe that you should have access, please contact an application administrator.'

          # Log this user out
          redirect_to(wind_logout_uri + '?passthrough=1&destination=' + URI::escape(root_url))
        end

      else
        render :inline => 'Wind Authentication failed, Please try again later.'
      end

    end

  end

  # GET /users/do_cas_login
  def do_cas_login

    cas_server_uri = 'https://cas.columbia.edu'
    cas_login_uri = cas_server_uri + '/cas/login'
    cas_validate_uri = cas_server_uri + '/cas/serviceValidate'
    cas_logout_uri = cas_server_uri + '/cas/logout'

    if user_signed_in?
      redirect_to root_path
    end

    if ! params[:ticket]

      # Login: Part 1

      # If ticket is NOT set, this means that the user hasn't gotten to the uni/password login page yet.  Let's send them there.
      # After they log in, they'll be redirected to this page and they'll continue with the authentication.

      redirect_to(cas_login_uri + '?service=' + URI::escape(request.protocol + request.host_with_port + '/users/do_cas_login'))

    else
      # Login: Part 2
      # If ticket is set, we'll use that ticket for login part 2.

      #We'll validate the ticket against the wind server
      full_validate_uri = cas_validate_uri + '?service=' + URI::escape(request.protocol + request.host_with_port + '/users/do_cas_login') + '&ticket=' + params['ticket']

      uri = URI.parse(full_validate_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env == 'development'

      cas_request = Net::HTTP::Get.new(uri.request_uri)
      response_body = http.request(cas_request).body

      user_uni = nil

      # We are always expecting an XML response
      xml_response = Nokogiri::XML(response_body)
      xpath_selection = xml_response.xpath('/cas:serviceResponse/cas:authenticationSuccess/cas:user', {'cas' => 'http://www.yale.edu/tp/cas'})
      if xpath_selection.present?
        user_uni = xpath_selection.first.text
      end

      if user_uni.present?

        possible_user = User.where(email: (user_uni + '@columbia.edu')).first

        unless possible_user.nil?
          sign_in possible_user, :bypass => true
          session[:signed_in_using_uni] = true # TODO use this session variable to know when to do a Wind logout upon Devise logout
          flash[:notice] = 'You are now logged in.'

          redirect_to root_path, :status => 302
        else
          flash[:notice] = 'The UNI ' + user_uni + ' is not authorized to log into Hyacinth (no account exists with email ' + user_uni + '@columbia.edu).  If you believe that you should have access, please contact an application administrator.'

          # Log this user out
          redirect_to(cas_logout_uri + '?service=' + URI::escape(root_url))
        end

      else
        render :inline => 'Wind Authentication failed, Please try again later.'
      end

    end

  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html {
          if params[:change_password]
            redirect_to edit_user_url(@user), notice: 'Password successfully updated.'
          else
            redirect_to @user, notice: 'User was successfully updated.'
          end
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy

    # Before deleting a user, verify that at least one admin user still exists
    if(User.where(is_admin: true).where.not(id: @user.id).count == 0)
      flash[:alert] = 'You cannot delete the only remaining admin user.'
    else
      @user.destroy
    end

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :current_password, :is_admin)
  end

  def set_contextual_nav_options

    @contextual_nav_options['nav_title']['label'] = 'Users'
    @contextual_nav_options['nav_title']['url'] = users_path

    case params[:action]
    when 'index'
      @contextual_nav_options['nav_items'].push(label: 'Add New User', url: new_user_path)
    when 'show'
      @contextual_nav_options['nav_items'].push(label: '<span class="glyphicon glyphicon-edit"></span> Edit This User'.html_safe, url: edit_user_path(@user.id))
    when 'edit', 'update'
      @contextual_nav_options['nav_items'].push(label: 'Delete This User', url: user_path(@user.id), options: {method: :delete, data: { confirm: 'Are you sure you want to delete this User?' } })

      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Users'.html_safe
      @contextual_nav_options['nav_title']['url'] = users_path
    end

  end

end

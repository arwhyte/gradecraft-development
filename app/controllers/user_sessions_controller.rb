class UserSessionsController < ApplicationController

  skip_before_filter :require_login, :except => [:destroy, :new, :index]

  def new
    @user = User.new
  end

  def create
    respond_to do |format|
      if @user = login(params[:user][:email],params[:user][:password],params[:user][:remember_me])
        FNORD_METRIC.event(_type: "_set_name", name: current_user.public_name, _session: current_user.id.to_s, _namespace: 'gradecraft')
        FNORD_METRIC.event(_type: "_set_picture", url: GravatarImageTag::gravatar_url(current_user.email.downcase), _session: current_user.id.to_s, _namespace: 'gradecraft')
        #User.increment_counter(:visit_count, current_user.id) if current_user
        format.html { redirect_back_or_to dashboard_path }
        format.xml { render :xml => @users, :status => :created, :location => @user }
      else
        @user = User.new
        format.html { flash.now[:alert] = "Login failed."; render :action => "new" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    logout
    redirect_to "https://weblogin.umich.edu/cgi-bin/logout?http://www.umich.edu", :notice => "Logged out!"
  end

end

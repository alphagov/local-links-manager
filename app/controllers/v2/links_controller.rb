module V2
  class LinksController < ApplicationController
    before_action :load_dependencies

    def edit
      session[:return_to_from_link_edit] = (request.headers["Referer"])
    end

    def update
      @link.url = params[:link][:url].strip

      if @link.save
        redirect
      else
        flash.now[:danger] = "Please enter a valid link."
        render :edit
      end
    end

    def destroy
      if @link.destroy
        redirect('deleted')
      else
        flash.now[:danger] = "Could not delete link."
        render :edit
      end
    end

    def where_we_came_from_url
      session[:return_to_from_link_edit] || v2_root_path
    end
    helper_method :where_we_came_from_url

  private

    def load_dependencies
      @local_authority = LocalAuthorityPresenter.new(LocalAuthority.find_by(slug: params[:local_authority_slug]))
      @interaction = Interaction.find_by(slug: params[:interaction_slug])
      @service = Service.find_by(slug: params[:service_slug])
      @link = Link.retrieve(params)
    end

    def redirect(action = 'saved')
      flash[:success] = "Link has been #{action}."
      redirect_to where_we_came_from_url
    end
  end
end

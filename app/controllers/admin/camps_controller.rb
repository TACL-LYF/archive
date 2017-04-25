module Admin
  class CampsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Camp.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Camp.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    # override default show method
    def show
      render locals: {
        page: Administrate::Page::Show.new(dashboard, requested_resource),
        breakdown: requested_resource.get_summary
      }
    end
  end
end

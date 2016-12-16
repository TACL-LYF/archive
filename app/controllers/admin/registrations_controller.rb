module Admin
  class RegistrationsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Registration.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Registration.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    def resource_params
      params.require(:registration).permit(
        permitted_attributes
          .push(*Registration.stored_attributes[:additional_shirts])
          .push(*Registration.stored_attributes[:camper_involvement]))
    end
  end
end

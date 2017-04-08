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

    def index
      search_term = params[:search].to_s.strip
      resources = Administrate::Search.new(resource_resolver, search_term).run

      respond_to do |format|
        format.html do
          search_term = params[:search].to_s.strip
          resources = Administrate::Search.new(resource_resolver, search_term).run
          resources = order.apply(resources)
          resources = resources.page(params[:page]).per(records_per_page)
          page = Administrate::Page::Collection.new(dashboard, order: order)

          render locals: {
            resources: resources,
            search_term: search_term,
            page: page,
          }
        end

        format.csv { send_data resources.to_csv }
        format.xlsx { @resources = resources }
      end
    end
  end
end

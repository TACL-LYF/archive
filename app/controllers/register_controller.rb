class RegisterController < ApplicationController
  include Wicked::Wizard
  layout :registration_layout

  all_steps = ["landing"] | Family.reg_steps | Camper.reg_steps | Registration.reg_steps |
    ["siblings"] | RegistrationPayment.reg_steps | ["confirmation"]
  steps *all_steps

  def show
    @current_step = step
    @outline = get_outline
    case step
    when "landing"
      clear_session
    when "parent"
      @family = Family.new(session[:family])
      @family.valid? if flash[:form_has_errors]
    when "referral"
      @family = Family.new(session[:family])
      @rm_ids = @family.referrals.collect{|r| r.referral_method_id}
      @referrals = initialize_referrals(@family)
      @family.valid? if flash[:form_has_errors]
    when "camper"
      @new_sibling = !session[:campers].nil?
      @camper = build_camper(session[:camper])
      @camper.valid? if flash[:form_has_errors]
    when "details"
      @shirt_sizes = Registration.stored_attributes[:additional_shirts]
      @reg = build_reg(session[:camper], session[:reg])
      @reg.valid? if flash[:form_has_errors]
    when "camper_involvement"
      if eligible_for_camper_involvement
        @camper_roles = Registration.stored_attributes[:camper_involvement]
        @reg = build_reg(session[:camper], session[:reg])
        @reg.valid? if flash[:form_has_errors]
      else
        skip_step
      end
    when "waiver"
      @camper_involvement = eligible_for_camper_involvement
      @reg = build_reg(session[:camper], session[:reg])
      @reg.valid? if flash[:form_has_errors]
    when "review"
      @camper = build_camper(session[:camper])
      @reg = build_reg(session[:camper], session[:reg])
    when "siblings"
      clear_current_registration
      @regs = session[:campers].collect{ |c| c["first_name"]+" "+c["last_name"]}
    when "donation"
      @payment = build_payment
      @payment.valid? if flash[:form_has_errors]
    when "payment"
      @payment = build_payment
      @payment.calculate_total
      @breakdown = @payment.breakdown
      @payment.valid? if flash[:form_has_errors]
    end
    render_wizard
  end

  def update
    case step
    when "parent"
      famparams = family_params(step)
      session[:family] ||= {}
      session[:family] = session[:family].merge(famparams.to_h).delete_if {|k,v| v.blank?}
      @family = Family.new(session[:family])
      if @family.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "referral"
      famparams = family_params(step)
      famparams[:referrals_attributes].delete_if {|k,v| v[:_destroy] == "1"}
      session[:family] = session[:family].merge(famparams.to_h)
      @family = Family.new(session[:family])
      if @family.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "camper"
      session[:camper] ||= {}
      camparams = camper_params(step).delete_if {|k,v| v.blank?}
      session[:camper] = session[:camper].merge(camparams.to_h)
      @camper = build_camper(session[:camper])
      if @camper.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "details"
      session[:reg] ||= {}
      regparams = reg_params(step)
      session[:reg] = session[:reg].merge(regparams.to_h).delete_if {|k,v| v.blank? || v == "0"}
      @reg = build_reg(session[:camper], session[:reg])
      if @reg.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "camper_involvement"
      session[:reg] = session[:reg].merge(reg_params(step).to_h).delete_if {|k,v| v.blank?}
      @reg = build_reg(session[:camper], session[:reg])
      if @reg.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "waiver"
      session[:reg] = session[:reg].merge(reg_params(step).delete_if {|k,v| v.blank?}.to_h)
      @reg = build_reg(session[:camper], session[:reg])
      if @reg.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "review"
      store_reg_in_session
      redirect_to wizard_path(next_step)
    when "siblings"
      if params[:wizard].nil?
        flash[:danger] = 'Please select an option.'
        redirect_to wizard_path
      else
        sibling = params[:wizard][:sibling]
        if sibling == "new"
          flash[:info] = 'Please enter details for the sibling you would like to register.'
          redirect_to wizard_path(:camper)
        elsif sibling == "none"
          redirect_to wizard_path(next_step)
        else
          flash[:danger] = 'Please select a valid option.'
          redirect_to wizard_path
        end
      end
    when "donation"
      if params[:registration_payment][:additional_donation] == "other"
        amount = params[:registration_payment][:donation_amount]
        params[:registration_payment][:additional_donation] = amount
      end
      session[:payment] ||= {}
      session[:payment] = session[:payment].merge(payment_params(step).to_h).delete_if {|k,v| v.blank? || v == "0"}
      @payment = build_payment
      if @payment.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "payment"
      if params[:apply_code]
        code = params[:registration_payment][:discount_code]
        discount = RegistrationDiscount.get(code)
        if discount.nil?
          flash[:danger] = "Error: #{code} is not a valid code"
          redirect_to wizard_path
        else
          session[:payment][:discount_code] = code
          flash[:info] = "Code #{code} successfully applied"
          redirect_to wizard_path
        end
      else
        begin
          @family = Family.new(session[:family])
          city = @family.city
          state = @family.state
          stripe_token = stripe_params(step)[:stripe_card_token]
          @family.transaction do
            @payment = RegistrationPayment.new(session[:payment].merge(stripe_token: stripe_token))
            campers = session[:campers]
            campers.each_with_index do |camper, i|
              reg_fields = session[:regs][i].merge(camp: Camp.first, city: city,
                state: state)
              c = @family.campers.build(camper)
              r = c.registrations.build(reg_fields)
              @payment.registrations << r
            end
            if @family.save!
              if @payment.save!
                RegistrationPaymentMailer.registration_confirmation(@payment).deliver_now
                clear_session
                redirect_to wizard_path(:confirmation)
              else
                flash[:danger] = "Something went wrong."
                redirect_to wizard_path
              end
            else
              flash[:danger] = "Something went wrong."
              redirect_to wizard_path
            end
          end
        rescue Stripe::CardError => e
          msg = log_error_to_debugger_and_return_msg(e)
          flash[:danger] = "There was a problem processing your payment: #{msg}"
          redirect_to wizard_path
        rescue Stripe::RateLimitError => e
          # Too many requests made to the API too quickly
          msg = log_error_to_debugger_and_return_msg(e)
          flash[:danger] = "There was a problem processing your payment: #{msg} Please try again in a bit."
          redirect_to wizard_path
        rescue Stripe::InvalidRequestError => e
          # Invalid parameters were supplied to Stripe's API
          msg = log_error_to_debugger_and_return_msg(e)
          flash[:danger] = "There was a problem processing your payment: #{msg}"
          redirect_to wizard_path
        rescue Stripe::AuthenticationError => e
          # Authentication with Stripe's API failed
          # (maybe you changed API keys recently)
          msg = log_error_to_debugger_and_return_msg(e)
          flash[:danger] = "There was a problem processing your payment: #{msg}"
          redirect_to wizard_path
        rescue Stripe::APIConnectionError => e
          # Network communication with Stripe failed
          msg = log_error_to_debugger_and_return_msg(e)
          flash[:danger] = "There was a problem processing your payment: #{msg}"
          redirect_to wizard_path
        rescue Stripe::StripeError => e
          # Display a very generic error to the user, and maybe send
          # yourself an email
          msg = log_error_to_debugger_and_return_msg(e)
          flash[:danger] = "There was a problem processing your payment."
          redirect_to wizard_path
        rescue => e
          logger.debug "Error submitting registration form"
          logger.debug e
          flash[:danger] = "Something went wrong."
          redirect_to wizard_path
        end
      end
    end
  end

  private
    def family_params(step)
      permitted_attrs = case step
        when "parent"
          [:primary_parent_first_name, :primary_parent_last_name,
            :primary_parent_email, :primary_parent_phone_number,
            :secondary_parent_first_name, :secondary_parent_last_name,
            :secondary_parent_email, :secondary_parent_phone_number, :suite,
            :street, :city, :state, :zip]
        when "referral"
          [referrals_attributes: [:referral_method_id, :details, :_destroy]]
        end
      params.require(:family).permit(permitted_attrs).merge(reg_step: step)
    end

    def camper_params(step)
      permitted_attrs = case step
        when "camper"
          [:first_name, :last_name, :gender, :birthdate, :email, :returning,
            :medical_conditions_and_medication, :diet_and_food_allergies]
        end
      params.require(:camper).permit(permitted_attrs).merge(reg_step: step)
    end

    def reg_params(step)
      permitted_attrs = case step
        when "details"
          [:grade, :shirt_size, :jtasa_chapter, :bus].push(*Registration.stored_attributes[:additional_shirts])
        when "waiver"
          [:additional_notes, :waiver_signature, :waiver_date]
        when "camper_involvement"
          Registration.stored_attributes[:camper_involvement]
        end
      params.require(:registration).permit(permitted_attrs).merge(reg_step: step)
    end

    def payment_params(step)
      permitted_attrs = case step
        when "donation"
          [:additional_donation, :donation_amount]
        end
      params.require(:registration_payment).permit(permitted_attrs).merge(reg_step: step)
    end

    def stripe_params(step)
      permitted_attrs = case step
        when "payment"
          [:stripe_card_token]
        end
      params.require(:wizard).permit(permitted_attrs).merge(reg_step: step)
    end

    def initialize_referrals(family)
      rm_ids = family.referrals.collect{|r| r.referral_method_id}
      ReferralMethod.all.each do |rm|
        unless rm_ids.include?(rm.id)
          family.referrals.build(referral_method_id: rm.id)
        end
      end
      return family.referrals.sort_by(&:referral_method_id)
    end

    def build_camper(camper_attrs)
      camper = Camper.new(camper_attrs)
      camper.build_family(session[:family])
      return camper
    end

    def build_reg(camper_attrs, reg_attrs)
      camper = build_camper(camper_attrs)
      reg_attrs ||= {}
      reg = camper.registrations.build(reg_attrs.merge(camp: Camp.first,
        city: session[:family]["city"], state: session[:family]["state"]))
      return reg
    end

    def build_payment
      payment = RegistrationPayment.new(session[:payment])
      session[:regs].each_with_index do |reg_attrs, i|
        r = build_reg(session[:campers][i], reg_attrs)
        payment.registrations << r
      end
      return payment
    end

    def eligible_for_camper_involvement
      session[:camper]["returning"] == "true" && session[:reg]["grade"].to_i >= 10
    end

    def store_reg_in_session
      session[:campers] ||= []
      session[:regs] ||= []
      session[:campers] << session[:camper]
      session[:regs] << session[:reg]
    end

    def clear_current_registration
      session[:camper] = nil
      session[:reg] = nil
    end

    def clear_session
      session[:family] = nil
      session[:campers] = nil
      session[:regs] = nil
      session[:camper] = nil
      session[:reg] = nil
      session[:payment] = nil
    end

    def registration_layout
      step == "landing" ? "registration_landing" : "registration_form"
    end

    def get_outline
      outline = {
        parent_info: [ "parent", "referral" ],
        camper_info: [ "camper", "details", "waiver", "coordinator", "review" ],
        register_a_sibling: [ "siblings" ],
        add_a_donation: [ "donation" ],
        payment: [ "payment" ],
        confirmation: [ "confirmation" ]
      }
      return outline
    end

    def log_error_to_debugger_and_return_msg(e)
      err = e.json_body[:error]
      logger.debug "Status is: #{e.http_status}"
      logger.debug "Type is: #{err[:type]}"
      logger.debug "Code is: #{err[:code]}"
      logger.debug "Param is: #{err[:param]}"
      logger.debug "Message is: #{err[:message]}"
      return err[:message]
    end

    # TODO: handle session overflow
end

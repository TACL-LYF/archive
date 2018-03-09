class RegistrationController < ApplicationController
  include Wicked::Wizard
  before_action :get_reg_session_and_prepare_exception_notifier
  layout :registration_layout

  all_steps = ["landing"] | Family.reg_steps | Camper.reg_steps | Registration.reg_steps |
    ["siblings"] | RegistrationPayment.reg_steps | ["confirmation"]
  steps *all_steps

  def show
    @current_step = step
    @outline = get_outline
    @camp = Camp.first
    case step
    when "landing"
      delete_reg_session
    when "parent"
      @family = Family.new(@reg_session.family)
      @family.valid? if flash[:form_has_errors]
    when "referral"
      @family = Family.new(@reg_session.family)
      @rm_ids = @family.referrals.collect{|r| r.referral_method_id}
      @referrals = initialize_referrals(@family)
      @family.valid? if flash[:form_has_errors]
    when "camper"
      @new_sibling = !@reg_session.campers.blank?
      @camper = build_camper(@reg_session.camper)
      @camper.valid? if flash[:form_has_errors]
    when "details"
      @shirt_sizes = Registration.stored_attributes[:additional_shirts]
      @reg = build_reg(@reg_session.camper, @reg_session.reg)
      @reg.valid? if flash[:form_has_errors]
    when "camper_involvement"
      if eligible_for_camper_involvement
        @camper_roles = Registration.stored_attributes[:camper_involvement]
        @reg = build_reg(@reg_session.camper, @reg_session.reg)
        @reg.valid? if flash[:form_has_errors]
      else
        skip_step
      end
    when "waiver"
      @camper_involvement = eligible_for_camper_involvement
      @reg = build_reg(@reg_session.camper, @reg_session.reg)
      @reg.valid? if flash[:form_has_errors]
    when "review"
      @camper = build_camper(@reg_session.camper)
      @reg = build_reg(@reg_session.camper, @reg_session.reg)
    when "siblings"
      @regs = @reg_session.campers.collect{ |c| c["first_name"]+" "+c["last_name"]}
    when "donation"
      @payment = build_payment
      @payment.valid? if flash[:form_has_errors]
    when "payment"
      @payment = build_payment
      @payment.calculate_total unless @reg_session.payment.blank?
      @breakdown = @payment.breakdown
    end
    render_wizard
  end

  def update
    case step
    when "parent"
      famparams = family_params(step)
      @reg_session.family.merge!(famparams.to_h).delete_if {|k,v| v.blank?}
      @reg_session.save
      session[:reg_session_id] = @reg_session.id
      if Family.new(@reg_session.family).valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "referral"
      famparams = family_params(step)
      famparams[:referrals_attributes].delete_if {|k,v| v[:_destroy] == "1"}
      @reg_session.family.merge!(famparams.to_h)
      @reg_session.save
      if Family.new(@reg_session.family).valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "camper"
      camparams = camper_params(step)
      @reg_session.camper.merge!(camparams.to_h).delete_if {|k,v| v.blank?}
      @reg_session.save
      if build_camper(@reg_session.camper).valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "details"
      regparams = reg_params(step)
      @reg_session.reg.merge!(regparams.to_h).delete_if {|k,v| v.blank? || v == "0"}
      @reg_session.save
      if build_reg(@reg_session.camper, @reg_session.reg).valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "camper_involvement"
      @reg_session.reg = @reg_session.reg.merge(reg_params(step).to_h).delete_if {|k,v| v.blank?}
      @reg_session.save
      if build_reg(@reg_session.camper, @reg_session.reg).valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "waiver"
      @reg_session.reg.merge!(reg_params(step).to_h.delete_if {|k,v| v.blank?}.to_h)
      @reg_session.save
      if build_reg(@reg_session.camper, @reg_session.reg).valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "review"
      @reg_session.campers << @reg_session.camper
      @reg_session.regs << @reg_session.reg
      @reg_session.camper = {}
      @reg_session.reg = {}
      @reg_session.save
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
      @reg_session.payment.merge!(payment_params(step).to_h).delete_if {|k,v| v.blank? || v == "0"}
      @reg_session.save
      if build_payment.valid?
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
          @reg_session.payment[:discount_code] = code
          @reg_session.save
          flash[:info] = "Code #{code} successfully applied"
          redirect_to wizard_path
        end
      else
        begin
          @family = Family.new(@reg_session.family)
          city = @family.city
          state = @family.state
          stripe_token = stripe_params(step)[:stripe_card_token]
          @family.transaction do
            @payment = RegistrationPayment.new(@reg_session.payment.merge(stripe_token: stripe_token))
            campers = @reg_session.campers
            campers.each_with_index do |camper, i|
              reg_fields = @reg_session.regs[i].merge(camp: Camp.first, city: city,
                state: state)
              c = @family.campers.build(camper)
              r = c.registrations.build(reg_fields)
              @payment.registrations << r
            end
            if @family.save!
              if @payment.save!
                RegistrationPaymentMailer.registration_confirmation(@payment).deliver_now
                delete_reg_session
                redirect_to wizard_path(:confirmation)
              else
                flash[:form_has_errors] = true
                redirect_to wizard_path
              end
            else
              flash[:danger] = "Something went wrong."
              redirect_to wizard_path
            end
          end
        rescue ActiveRecord::RecordNotSaved => e
          flash[:danger] = @payment.errors.full_messages.join(" ").chomp(" ")
          redirect_to wizard_path
        rescue => e
          logger.warn "Error submitting registration form"
          logger.warn e
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
          [:first_name, :last_name, :gender, :birth_year, :birth_month,
            :birth_day, :email, :returning, :medical_conditions_and_medication,
            :diet_and_food_allergies]
        end
      params.require(:camper).permit(permitted_attrs).merge(reg_step: step)
    end

    def reg_params(step)
      permitted_attrs = case step
        when "details"
          [:grade, :shirt_size, :jtasa_chapter, :bus].push(*Registration.stored_attributes[:additional_shirts])
        when "waiver"
          [:additional_notes, :waiver_signature, :waiver_year, :waiver_month, :waiver_day]
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

    def get_reg_session(step)
      reg_session = RegSession.find_by(id: session[:reg_session_id])
      if session[:reg_session_id].nil? || reg_session.nil?
        set_interrupted_session_flash unless %w[landing parent confirmation].include?(step)
        RegSession.new(family: {}, campers: [], regs: [], camper: {}, reg: {},
          payment: {})
      else
        unless %w[landing parent confirmation].include?(step)
          if reg_session.family.blank?
            set_interrupted_session_flash
          elsif reg_session.camper.blank? && %w[details camper_involvement waiver review].include?(step)
            set_interrupted_session_flash
          elsif reg_session.reg.blank? && %w[camper_involvement waiver review].include?(step)
            set_interrupted_session_flash
          elsif (reg_session.regs.blank? || reg_session.campers.blank?) && %w[siblings donation payment].include?(step)
            set_interrupted_session_flash
          end
        end
        return reg_session
      end
    end

    def set_interrupted_session_flash
      msg = %Q[Oops! You're in the middle of the form, but we seem to have lost]
      msg += %Q[ some of your previously entered information.<br />]
      msg += %Q[Please <a href="/registration/landing">start again from the beginning</a>]
      msg += %Q[, or email <a href="mailto:rosette.su@tacl.org">rosette.su@tacl.org</a>]
      msg += %Q[ if the problem persists.]
      flash.now[:danger] = msg.html_safe
    end

    def delete_reg_session
      reg_session_id = session[:reg_session_id]
      reg_session = RegSession.find_by(id: reg_session_id)
      reg_session.destroy unless reg_session_id.nil? || reg_session.nil?
      session.delete(:reg_session_id)
    end

    def initialize_referrals(family)
      rm_ids = family.referrals.collect{|r| r.referral_method_id}
      ReferralMethod.all.each do |rm|
        unless rm_ids.include?(rm.id)
          family.referrals.build(referral_method_id: rm.id)
        end
      end
      return family.referrals.sort_by{|r| r.referral_method.name == "Other" ? 100 : r.referral_method_id }
    end

    def build_camper(camper_attrs)
      camper = Camper.new(camper_attrs)
      camper.build_family(@reg_session.family)
      return camper
    end

    def build_reg(camper_attrs, reg_attrs)
      camper = build_camper(camper_attrs)
      reg_attrs ||= {}
      reg = camper.registrations.build(reg_attrs.merge(camp: Camp.first,
        city: @reg_session.family["city"], state: @reg_session.family["state"]))
      return reg
    end

    def build_payment
      payment = RegistrationPayment.new(@reg_session.payment)
      @reg_session.regs.each_with_index do |reg_attrs, i|
        r = build_reg(@reg_session.campers[i], reg_attrs)
        payment.registrations << r
      end
      return payment
    end

    def eligible_for_camper_involvement
      @reg_session.camper["returning"]=="true" && @reg_session.reg["grade"].to_i>=10
    end

    def registration_layout
      step == "landing" ? "registration_landing" : "registration_form"
    end

    def get_outline
      outline = {
        parent_information: [ "parent" ],
        referral: [ "referral" ],
        camper_information: [ "camper", "details", "waiver", "camper_involvement", "review" ],
        register_a_sibling: [ "siblings" ],
        add_a_donation: [ "donation" ],
        payment: [ "payment" ],
        confirmation: [ "confirmation" ]
      }
      return outline
    end

    # store relevant session contents for exception notifier
    def get_reg_session_and_prepare_exception_notifier
      @reg_session = get_reg_session(step)
      request.env['exception_notifier.exception_data'] = {
        "FAMILY" => @reg_session.family,
        "CAMPERS" => @reg_session.campers,
        "REGS" => @reg_session.regs,
        "CURRENT CAMPER" => @reg_session.camper,
        "CURRENT REG" => @reg_session.reg,
        "PAYMENT" => @reg_session.payment
      }
    end
end

class RegisterController < ApplicationController
  include Wicked::Wizard

  beginning_steps = %w[begin]
  end_steps = %w[siblings donation payment confirmation]
  all_steps = beginning_steps | Family.reg_steps | Camper.reg_steps |
              Registration.reg_steps | end_steps
  steps *all_steps

  def show
    case step
    when "begin"
      clear_session
    when "parent"
      @family = Family.new(session[:family])
      @family.valid? if flash[:form_has_errors]
    when "referral"
      if session[:family]["first_time"] == "true"
        @family = Family.new(session[:family])
        @rm_ids = @family.referrals.collect{|r| r.referral_method_id}
        @referrals = initialize_referrals(@family)
        @family.valid? if flash[:form_has_errors]
      else
        skip_step
      end
    when "camper"
      @camper = build_camper_from_session
      @camper.valid? if flash[:form_has_errors]
    when "details"
      # TODO: handle extra shirts
      @reg = build_reg_from_session
      @reg.valid? if flash[:form_has_errors]
    when "waiver"
      @reg = build_reg_from_session
      @reg.valid? if flash[:form_has_errors]
    when "review"
      @camper = build_camper_from_session
      @reg = build_reg_from_session
    when "siblings"
      @regs = session[:campers].collect{ |c| c["first_name"]+" "+c["last_name"]}
    when "payment"
      @family = Family.new(session[:family])
    end
    render_wizard
  end

  def update
    case step
    when "parent"
      session[:family] = {} if session[:family].nil?
      session[:family] = session[:family].merge(family_params(step).to_h)
      @family = Family.new(session[:family])
      if @family.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "referral"
      session[:family] = session[:family].merge(family_params(step).to_h)
      @family = Family.new(session[:family])
      if @family.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "camper"
      session[:camper] = {} if session[:camper].nil?
      session[:camper] = session[:camper].merge(camper_params(step).to_h)
      @camper = build_camper_from_session
      if @camper.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "details"
      session[:reg] = {} if session[:family].nil?
      session[:reg] = session[:reg].merge(reg_params(step).to_h)
      @reg = build_reg_from_session
      if @reg.valid?
        redirect_to wizard_path(next_step)
      else
        flash[:form_has_errors] = true
        redirect_to wizard_path
      end
    when "waiver"
      session[:reg] = session[:reg].merge(reg_params(step).to_h)
      @reg = build_reg_from_session
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
      if params[:wizard].nil?
        amount = 0
      else
        amount = params[:wizard][:donation]
        amount = params[:wizard][:amount] if amount == "other"
      end
      session[:donation] = amount.to_f
      redirect_to wizard_path(next_step)
    when "payment"
      @family = Family.new(session[:family])
      city = @family.city
      state = @family.state
      @family.transaction do
        campers = session[:campers]
        campers.each_with_index do |camper, i|
          reg_fields = session[:regs][i].merge(camp: Camp.first, city: city,
            state: state)
          c = @family.campers.build(camper)
          c.registrations.build(reg_fields)
          c.save!
        end
        if @family.save!
          clear_session
          redirect_to wizard_path(:confirmation)
        else
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
            :street, :city, :state, :zip, :first_time]
        when "referral"
          [referrals_attributes: [:referral_method_id, :details, :_destroy]]
        end
      params.require(:family).permit(permitted_attrs).merge(reg_step: step)
    end

    def camper_params(step)
      permitted_attrs = case step
        when "camper"
          [:first_name, :last_name, :gender, :birthdate, :email,
            :medical_conditions_and_medication, :diet_and_food_allergies]
        end
      params.require(:camper).permit(permitted_attrs).merge(reg_step: step)
    end

    def reg_params(step)
      permitted_attrs = case step
        when "details"
          [:grade, :shirt_size, :bus].push(*Registration.stored_attributes[:additional_shirts])
        when "waiver"
          [:additional_notes, :waiver_signature, :waiver_date]
        end
      params.require(:registration).permit(permitted_attrs).merge(reg_step: step)
    end

    def initialize_referrals(family)
      rm_ids = family.referrals.collect{|r| r.referral_method_id}
      ReferralMethod.all.each do |rm|
        unless rm_ids.include?(rm.id)
          family.referrals.build(referral_method_id: rm.id)
        end
      end
      return family.referrals.sort_by &:referral_method_id
    end

    def build_camper_from_session
      camper = Camper.new(session[:camper])
      camper.build_family(session[:family])
      return camper
    end

    def build_reg_from_session
      camper = build_camper_from_session
      session[:reg] = {} if session[:reg].nil?
      reg = camper.registrations.build(session[:reg].merge(camp: Camp.first,
        city: session[:family]["city"], state: session[:family]["state"]))
      return reg
    end

    def store_reg_in_session
      session[:campers] = [] if session[:campers].nil?
      session[:regs] = [] if session[:regs].nil?
      session[:campers] << session[:camper]
      session[:regs] << session[:reg]
      session.delete(:camper)
      session.delete(:reg)
    end

    def clear_session
      session.delete(:family)
      session.delete(:referrals)
      session.delete(:campers)
      session.delete(:camper)
      session.delete(:regs)
      session.delete(:reg)
      session.delete(:donation)
    end

    # TODO: handle session overflow
end

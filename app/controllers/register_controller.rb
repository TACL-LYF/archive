class RegisterController < ApplicationController
  include Wicked::Wizard

  all_steps = ["begin"] | Family.reg_steps | Camper.reg_steps | Registration.reg_steps |
    ["siblings"] | RegistrationPayment.reg_steps | ["confirmation"]
  steps *all_steps

  def show
    case step
    when "begin"
      clear_session
    when "parent"
      @family = Family.new(session[:family])

      # famparams = @family
      # userid = {'USERID' => "015TAIWA7538"}
      # addrid = {'ID' => "0"}
      # builder = Builder::XmlMarkup.new do |xml|
      #   userid.each do | name, choice |
      #     xml.AddressValidateRequest( name, :USERID => choice ) {
      #       xml.IncludeOptionalElements "true"
      #       xml.ReturnCarrierRoute "true"
      #       addrid.each do | name, choice |
      #       xml.Address( name, :ID => choice ) {
      #         xml.FirmName
      #         xml.Address1 famparams[:suite]
      #         xml.Address2 famparams[:street]
      #         xml.City famparams[:city]
      #         xml.State famparams[:state]
      #         xml.Zip5 famparams[:zip]
      #         xml.Zip4
      #       }
      #       end
      #     }
      #   end
      # end
      # url = URI.parse("http://production.shippingapis.com/ShippingAPI.dll?API=Verify&XML=")
      # request = Net::HTTP::Post.new(url.path)
      # request.body = builder
      # response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      # if response
      #   puts 'hi'
      #   puts response
      #   @family.valid? if flash[:form_has_errors]
      # end

      # xml.instruct! :xml, :version => "1.1", :encoding => "UTF-8"

      # addr = {:Address1 => famparams[:suite], :Address2 => famparams[:street], => :City famparams[:city], :State => famparams[:state], :Zip5 => famparams[:zip]}
      # addr.to_xml(:root => %q[AddressValidateRequest USERID='015TAIWA7538']) include: {%q[Address ID='0']}

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
      @camper = build_camper(session[:camper])
      @camper.valid? if flash[:form_has_errors]
    when "details"
      @reg = build_reg(session[:camper], session[:reg])
      @reg.valid? if flash[:form_has_errors]
    when "waiver"
      @reg = build_reg(session[:camper], session[:reg])
      @reg.valid? if flash[:form_has_errors]
    when "review"
      @camper = build_camper(session[:camper])
      @reg = build_reg(session[:camper], session[:reg])
    when "siblings"
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

  require 'builder'
  require 'net/http'
  require 'uri'
  def update
    case step
    when "parent"
      famparams = family_params(step).delete_if {|k,v| v.blank?}
      session[:family] ||= {}
      session[:family] = session[:family].merge(famparams.to_h)
      @family = Family.new(session[:family])

      famparams = @family
      userid = {'USERID' => "015TAIWA7538"}
      addrid = {'ID' => "0"}
      builder = Nokogiri::XML::Builder.new do |xml|
        userid.each do | name, choice |
          xml.AddressValidateRequest( :USERID => choice ) {
            xml.IncludeOptionalElements "true"
            xml.ReturnCarrierRoute "true"
            addrid.each do | name, choice |
            xml.Address( :ID => choice ) {
              xml.FirmName
              xml.Address1 famparams[:suite]
              xml.Address2 famparams[:street]
              xml.City famparams[:city]
              xml.State famparams[:state]
              xml.Zip5 famparams[:zip]
              xml.Zip4
            }
            end
          }
        end
      end
      url = URI.parse("http://production.shippingapis.com/ShippingAPI.dll?API=Verify&XML=")
      request = Net::HTTP::Post.new(url.path)
      request.body = builder.to_xml(:skip_instruct => true)
      puts 'INPUT'
      puts request.body
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      if response
        puts 'OUTPUT'
        puts response.body
        if @family.valid?
          redirect_to wizard_path(next_step)
        else
          flash[:form_has_errors] = true
          redirect_to wizard_path
        end
      end

      # if @family.valid?
      #   redirect_to wizard_path(next_step)
      # else
      #   flash[:form_has_errors] = true
      #   redirect_to wizard_path
      # end
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
      regparams = reg_params(step).delete_if {|k,v| v.blank?}
      session[:reg] = session[:reg].merge(regparams.to_h)
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
      session[:payment] = session[:payment].merge(payment_params(step).delete_if {|k,v| v.blank?}.to_h)
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
            @payment.calculate_total
            @payment.process_payment
            if @payment.save!
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

    def store_reg_in_session
      session[:campers] ||= []
      session[:regs] ||= []
      session[:campers] << session[:camper]
      session[:regs] << session[:reg]
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

    # TODO: handle session overflow
end

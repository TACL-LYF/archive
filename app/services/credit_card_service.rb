require 'stripe'

class CreditCardService
  ChargeResult = ImmutableStruct.new(:charge_succeeded?,
                                     :error_messages,
                                     :charge_obj)
  def initialize(params)
    @token = params[:token]
    @amount = params[:amount]
    @desc = params[:desc]
  end

  def charge
    begin
      reject_if_amex
      charge_obj = external_charge_service.create(charge_attributes)
      ChargeResult.new(charge_succeeded: true, charge_obj: charge_obj)
    rescue external_error_class => e
      log_msg =  "Status: #{e.http_status}"
      if e.json_body
        err = e.json_body[:error]
        log_msg += " | Type: #{err[:type]} | Code: #{err[:code]}"
        log_msg += " | Param: #{err[:param]} | Message: #{err[:message]}"
      else
        log_msg += " | Message: #{e.message}"
      end
      Rails.logger.warn log_msg

      msg = "There was a problem processing your payment: #{e.message}"
      msg += " Please try again in a bit." if e.is_a? Stripe::RateLimitError
      ChargeResult.new(charge_succeeded: false, error_messages: msg)
    rescue Exceptions::AmexError => e
      Rails.logger.warn "Amex card submitted"
      ChargeResult.new(charge_succeeded: false,
                       error_messages: "Sorry, we do not accept American Express")

      # TODO: handle non-stripe errors, or leave for controller to handle
    end
  end

  def self.get_link(token)
    "https://dashboard.stripe.com/payments/#{token}"
  end

  private
    attr_reader :token, :amount, :desc

    def external_charge_service
      Stripe::Charge
    end

    def external_token_service
      Stripe::Token
    end

    def external_error_class
      Stripe::StripeError
    end

    def reject_if_amex
      card_obj = external_token_service.retrieve(token)
      if card_obj.card.brand == "American Express"
        raise Exceptions::AmexError
      end
    end

    def charge_attributes
      {
        source: token,
        amount: (amount*100).to_i,
        description: desc,
        currency: 'usd'
      }
    end
end

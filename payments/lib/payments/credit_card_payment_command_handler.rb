module Payments
  class CreditCardPaymentCommandHandler
    def initialize
      @event_store = Rails.configuration.event_store
    end

    def assign_payment_to_order(cmd)
      ActiveRecord::Base.transaction do
        with_credit_card_payment(cmd.payment_id) do |credit_card_payment|
          order_reference = Payments::OrderReference.new(cmd.order_id)

          credit_card_payment.assign_to_order(order_reference: order_reference)
        end
      end
    end

    def charge_credit_card(cmd)
      ActiveRecord::Base.transaction do
        with_credit_card_payment(cmd.payment_id) do |credit_card_payment|
          amount          = Payments::Amount.new(cmd.amount, cmd.currency)
          credit_card     = Payments::CreditCard.new(cmd.credit_card_token)
          payment_gateway = Payments::PayPalAdapter.new

          credit_card_payment.charge_credit_card(
            credit_card: credit_card, amount: amount, payment_gateway: payment_gateway
          )
        end
      end
    end

    def authorize_credit_card(cmd)
      ActiveRecord::Base.transaction do
        with_credit_card_payment(cmd.payment_id) do |credit_card_payment|
          amount      = Payments::Amount.new(cmd.amount, cmd.currency)
          credit_card = Payments::CreditCard.new(cmd.credit_card_token)
          payment_gateway = Payments::PayPalAdapter.new

          credit_card_payment.authorize_credit_card(
            credit_card: credit_card, amount: amount, payment_gateway: payment_gateway
          )
        end
      end
    end

    def capture_authorization(cmd)
      ActiveRecord::Base.transaction do
        with_credit_card_payment(cmd.payment_id) do |credit_card_payment|
          payment_gateway = Payments::PayPalAdapter.new
          credit_card_payment.capture_authorization(payment_gateway: payment_gateway)
        end
      end
    end

    def release_authorization(cmd)
      ActiveRecord::Base.transaction do
        with_credit_card_payment(cmd.payment_id) do |credit_card_payment|
          payment_gateway = Payments::PayPalAdapter.new
          credit_card_payment.release_authorization(payment_gateway: payment_gateway)
        end
      end
    end

    def refund_payment(cmd)
      ActiveRecord::Base.transaction do
        with_credit_card_payment(cmd.payment_id) do |credit_card_payment|
          payment_gateway = Payments::PayPalAdapter.new
          credit_card_payment.refund(payment_gateway: payment_gateway)
        end
      end
    end

    private

    def with_credit_card_payment(payment_id)
      Payments::CreditCardPayment.new(payment_id).tap do |credit_card_payment|
        load_credit_card_payment(payment_id, credit_card_payment)
        yield credit_card_payment
        store_credit_card_payment(credit_card_payment)
      end
    end

    def load_credit_card_payment(payment_id, credit_card_payment)
      credit_card_payment.load(stream_name(payment_id), event_store: @event_store)
    end

    def store_credit_card_payment(credit_card_payment)
      credit_card_payment.store(event_store: @event_store)
    end

    def stream_name(payment_id)
      "Payments::CreditCardPayment$#{payment_id}"
    end
  end
end

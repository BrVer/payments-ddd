module Payments
  PaymentGatewayError = Class.new(StandardError)
end
require_dependency 'payments/commands/assign_payment_to_order.rb'
require_dependency 'payments/commands/authorize_credit_catd.rb'
require_dependency 'payments/commands/capture_authorization.rb'
require_dependency 'payments/commands/charge_credit_card.rb'
require_dependency 'payments/commands/refund_payment.rb'
require_dependency 'payments/commands/release_authorization.rb'

require_dependency 'payments/events/authorization_capture_failed.rb'
require_dependency 'payments/events/authorization_captured.rb'
require_dependency 'payments/events/authorization_release_failed.rb'
require_dependency 'payments/events/authorization_released.rb'
require_dependency 'payments/events/payment_assigned_to_order.rb'
require_dependency 'payments/events/payment_assignment_failed.rb'
require_dependency 'payments/events/payment_authorization_failed.rb'
require_dependency 'payments/events/payment_authorized.rb'
require_dependency 'payments/events/payment_failed.rb'
require_dependency 'payments/events/payment_refund_failed.rb'
require_dependency 'payments/events/payment_refunded.rb'
require_dependency 'payments/events/payment_succeded.rb'

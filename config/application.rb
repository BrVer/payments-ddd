require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module PaymentsDdd
  class Application < Rails::Application
    config.load_defaults 5.2
    config.api_only = true

    config.paths.add 'command/lib', eager_load: true
    config.paths.add 'fulfillment/lib', eager_load: true
    config.paths.add 'inventory/lib', eager_load: true
    config.paths.add 'orders/lib', eager_load: true
    config.paths.add 'payments/lib', eager_load: true
    config.paths.add 'ui/lib', eager_load: true
  end
end

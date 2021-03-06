module Fulfillment
  class OrderCommandHandler
    def initialize
      @event_store = Rails.configuration.event_store
    end

    def accept_order(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          order.accept(cmd.order_lines)
        end
      end
    end

    def reject_order(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          order.reject(cmd.order_lines)
        end
      end
    end

    private

    def with_order(order_id)
      Fulfillment::Order.new(order_id).tap do |order|
        load_order(order_id, order)
        yield order
        store_order(order)
      end
    end

    def load_order(order_id, order)
      order.load(stream_name(order_id), event_store: @event_store)
    end

    def store_order(order)
      order.store(event_store: @event_store)
    end

    def stream_name(order_id)
      "Fulfillment::Order$#{order_id}"
    end
  end
end

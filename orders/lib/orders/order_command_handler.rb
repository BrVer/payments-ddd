module Orders
  class OrderCommandHandler
    def initialize
      @event_store = Rails.configuration.event_store
    end

    def place_order(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          order_lines = cmd.order_lines.each do |order_line|
            Orders::OrderLine.new(
              product_id: order_line[:product_id], sku: order_line[:sku], quantity: order_line[:quantity],
              price: order_line[:price], currency: order_line[:currency]
            )
          end
          order.place(order_lines)
        end
      end
    end

    def provide_shipping_info(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          shipping_info = Orders::ShippingInfo.new(
            receiver_name: cmd.receiver_name, shipping_address: cmd.shipping_address
          )

          order.provide_shipping_info(shipping_info: shipping_info)
        end
      end
    end

    def provide_contact_info(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          contact_info = Orders::ContactInfo.new(contact_phone_number: cmd.contact_phone_number)

          order.provide_contact_info(contact_info: contact_info)
        end
      end
    end

    def submit_order(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          order.submit
        end
      end
    end

    def ship_order(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          order.ship
        end
      end
    end

    def cancel_order(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          order.cancel
        end
      end
    end

    private

    def with_order(order_id)
      Orders::Order.new(order_id).tap do |order|
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
      "Orders::Order$#{order_id}"
    end
  end
end

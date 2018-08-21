# Defines a fulfillment type enum on fulfillment centers
# Used to make it possible to set fulfillment types in the
# engine initializer
module Spree
  module FulfillmentCenterDecorator
    def self.prepended(base)
      base.enum fulfillment_type: Spree::ExternalFulfillment.fulfillment_types
    end
  end
end

module Spree
  module ExternalFulfillment
    # Engine settings
    mattr_accessor :fulfillment_types
    mattr_accessor :fulfillment_request_notifier_class
    mattr_accessor :fulfillment_center_assigner_class
    mattr_accessor :line_item_fullfillment_instruction_builder_class

    class Engine < Rails::Engine
      require 'spree/core'
      isolate_namespace Spree
      engine_name 'solidus_external_fulfillment'

      # use rspec for tests
      config.generators do |g|
        g.test_framework :rspec
      end

      def self.activate
        Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
      end

      config.to_prepare(&method(:activate).to_proc)
      config.after_initialize {
        # Done initializing. The fulfillment_types should be set by now
        # so define a fulfillment type enum on the fulfillment center model
        Spree::FulfillmentCenter.prepend Spree::FulfillmentCenterDecorator
      }
    end
  end
end

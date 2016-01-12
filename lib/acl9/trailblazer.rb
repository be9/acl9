class ::Trailblazer::Operation
  module Acl9
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def self.extended base
        base.inheritable_attr :policy_config
      end
      
      def policy *args, &block
        raise ArgumentError, "Block must be supplied to policy" unless block

        self.policy_config = DSL.new policy_config, *args, &block
      end
    end

    def setup! params
      evaluate_policy(super)
    end

    def evaluate_policy params
      unless self.class.policy_config.(params)
        raise ::Acl9::AccessDenied
      end
    end

    class DSL < ::Acl9::Dsl::Base
      def initialize existing, *args, &block
        opts = args.last.is_a?(Hash) ? args.pop : {}

        @subject_key = opts[:subject_method] || ::Acl9::config[:default_subject_method]

        super

        if existing
          @allows = existing.allows.clone
          @denys  = existing.denys.clone
        end

        acl_block! &block
      end

      def call params
        check.(params)
      end

      private
      def _subject_ref
        "params[:#@subject_key]"
      end

      def _object_ref object_key
        "params[:#{object_key}]"
      end

      def _method_ref method
        method
      end

      def check
        return @check if @check

        check = <<-RUBY
          lambda do |params|
            #{allowance_expression}
          end
        RUBY

        @check = instance_eval check, __FILE__, __LINE__
      end
    end
  end
end

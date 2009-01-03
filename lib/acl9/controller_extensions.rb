require File.join(File.dirname(__FILE__), 'controller_extensions', 'filter_producer')

module Acl9
  module ControllerExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def access_control(opts = {}, &block)
        subject_method = opts.delete(:subject_method) || Acl9::config[:default_subject_method]

        raise ArgumentError, "Block must be supplied to access_control" unless block

        producer = Acl9::FilterProducer.new(subject_method)
        producer.acl(&block)

        filter = opts.delete(:filter)
        filter = true if filter.nil?

        if opts.delete(:debug)
          Rails::logger.debug "=== Acl9 access_control expression dump (#{self.to_s})"
          Rails::logger.debug producer.to_s
          Rails::logger.debug "======"
        end

        if method = opts.delete(:as_method)
          class_eval producer.to_method_code(method, filter)

          before_filter(method, opts) if filter
        else
          before_filter(opts, &producer.to_proc)
        end
      end
    end
  end
end

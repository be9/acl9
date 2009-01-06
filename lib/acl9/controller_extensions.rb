require File.join(File.dirname(__FILE__), 'controller_extensions', 'generators')

module Acl9
  module ControllerExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def access_control(*args, &block)
        opts = if args.last.is_a? Hash
                 args.pop
               else
                 {}
               end

        case args.size
        when 0 then true
        when 1
          meth = args.first

          if meth.is_a? Symbol
            opts[:as_method] = meth
          else
            raise ArgumentError, "access control argument must be a :symbol!"
          end
        else
          raise ArgumentError, "Invalid arguments for access_control"
        end

        subject_method = opts.delete(:subject_method) || Acl9::config[:default_subject_method]

        raise ArgumentError, "Block must be supplied to access_control" unless block

        filter = opts.delete(:filter)
        filter = true if filter.nil?

        method = opts.delete(:as_method)

        generator = case
                    when method && filter
                      Acl9::Dsl::Generators::FilterMethod.new(subject_method, method)
                    when method && !filter
                      Acl9::Dsl::Generators::BooleanMethod.new(subject_method, method)
                    else
                      Acl9::Dsl::Generators::FilterLambda.new(subject_method)
                    end

        generator.acl_block!(&block)
        
        if opts.delete(:debug)
          Rails::logger.debug "=== Acl9 access_control expression dump (#{self.to_s})"
          Rails::logger.debug generator.to_s
          Rails::logger.debug "======"
        end

        generator.install_on(self, opts)
      end
    end
  end
end

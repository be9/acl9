require File.join(File.dirname(__FILE__), 'controller_extensions', 'generators')

module Acl9
  module ControllerExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def access_control(*args, &block)
        opts = args.extract_options!

        case args.size
        when 0 then true
        when 1
          meth = args.first

          if meth.is_a? Symbol
            opts[:as_method] = meth
          else
            raise ArgumentError, "access_control argument must be a :symbol!"
          end
        else
          raise ArgumentError, "Invalid arguments for access_control"
        end

        subject_method = opts[:subject_method] || Acl9::config[:default_subject_method]

        raise ArgumentError, "Block must be supplied to access_control" unless block

        filter = opts[:filter]
        filter = true if filter.nil?

        case helper = opts[:helper]
        when true
          raise ArgumentError, "you should specify :helper => :method_name" if !opts[:as_method]
        when nil then nil
        else
          if opts[:as_method]
            raise ArgumentError, "you can't specify both method name and helper name" 
          else
            opts[:as_method] = helper
            filter = false
          end
        end

        method = opts[:as_method]

        query_method_available = true
        generator = case
                    when method && filter
                      Acl9::Dsl::Generators::FilterMethod.new(subject_method, method)
                    when method && !filter
                      query_method_available = false
                      Acl9::Dsl::Generators::BooleanMethod.new(subject_method, method)
                    else
                      Acl9::Dsl::Generators::FilterLambda.new(subject_method)
                    end

        generator.acl_block!(&block)

        generator.install_on(self, opts)

        if query_method_available && (query_method = opts.delete(:query_method))
          case query_method
          when true
            if method
              query_method = "#{method}?"
            else
              raise ArgumentError, "You must specify :query_method as Symbol"
            end
          when Symbol, String
            # okay here
          else
            raise ArgumentError, "Invalid value for :query_method"
          end

          second_generator = Acl9::Dsl::Generators::BooleanMethod.new(subject_method, query_method)
          second_generator.acl_block!(&block)
          second_generator.install_on(self, opts)
        end
      end
    end
  end
end

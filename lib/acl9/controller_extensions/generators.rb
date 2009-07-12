require File.join(File.dirname(__FILE__), 'dsl_base')

module Acl9
  ##
  # This exception is raised whenever ACL block finds that the current user
  # is not authorized for the controller action he wants to execute.
  # @example How to catch this exception in ApplicationController
  #   class ApplicationController < ActionController::Base
  #     rescue_from 'Acl9::AccessDenied', :with => :access_denied
  #
  #     # ...other stuff...
  #     private
  #
  #     def access_denied
  #       if current_user
  #         # It's presumed you have a template with words of pity and regret
  #         # for unhappy user who is not authorized to do what he wanted
  #         render :template => 'home/access_denied'
  #       else
  #         # In this case user has not even logged in. Might be OK after login.
  #         flash[:notice] = 'Access denied. Try to log in first.'
  #         redirect_to login_path
  #       end
  #     end
  #   end
  #
  class AccessDenied < StandardError; end

  ##
  # This exception is raised when acl9 has generated invalid code for the
  # filtering method or block. Should never happen, and it's a bug when it
  # happens.
  class FilterSyntaxError < StandardError; end

  module Dsl
    module Generators
      class BaseGenerator < Acl9::Dsl::Base
        def initialize(*args)
          @subject_method = args[0]

          super
        end

        protected

        def _access_denied
          "raise Acl9::AccessDenied"
        end

        def _subject_ref
          "#{_controller_ref}send(:#{@subject_method})"
        end

        def _object_ref(object)
          "#{_controller_ref}instance_variable_get('@#{object}')"
        end

        def _action_ref
          "#{_controller_ref}action_name"
        end

        def _method_ref(method)
          "#{_controller_ref}send(:#{method})"
        end

        def _controller_ref
          @controller ? "#{@controller}." : ''
        end

        def install_on(controller_class, options)
          debug_dump(controller_class) if options[:debug]
        end

        def debug_dump(klass)
          return unless logger
          logger.debug "=== Acl9 access_control expression dump (#{klass.to_s})"
          logger.debug self.to_s
          logger.debug "======"
        end

        def logger
          ActionController::Base.logger
        end
      end

      class FilterLambda < BaseGenerator
        def initialize(subject_method)
          super

          @controller = 'controller'
        end

        def install_on(controller_class, options)
          super

          controller_class.send(:before_filter, options, &self.to_proc)
        end

        def to_proc
          code = <<-RUBY
            lambda do |controller|
              unless #{allowance_expression}
                #{_access_denied}
              end
            end
          RUBY

          self.instance_eval(code, __FILE__, __LINE__)
        rescue SyntaxError
          raise FilterSyntaxError, code
        end
      end

      ################################################################

      class FilterMethod < BaseGenerator
        def initialize(subject_method, method_name)
          super

          @method_name = method_name
          @controller = nil
        end

        def install_on(controller_class, options)
          super
          _add_method(controller_class)
          controller_class.send(:before_filter, @method_name, options)
        end

        protected

        def _add_method(controller_class)
          code = self.to_method_code
          controller_class.send(:class_eval, code, __FILE__, __LINE__)
        rescue SyntaxError
          raise FilterSyntaxError, code
        end

        def to_method_code
          <<-RUBY
            def #{@method_name}
              unless #{allowance_expression}
                #{_access_denied}
              end
            end
          RUBY
        end
      end

      ################################################################

      class BooleanMethod < FilterMethod
        def install_on(controller_class, opts)
          debug_dump(controller_class) if opts[:debug]

          _add_method(controller_class)

          if opts[:helper]
            controller_class.send(:helper_method, @method_name)
          end
        end

        protected

        def to_method_code
          <<-RUBY
            def #{@method_name}(*args)
              options = args.extract_options!

              unless args.size <= 1
                raise ArgumentError, "call #{@method_name} with 0, 1 or 2 arguments"
              end

              action_name = args.empty? ? self.action_name : args.first.to_s

              return #{allowance_expression}
            end
          RUBY
        end

        def _object_ref(object)
          "(options[:#{object}] || #{super})"
        end
      end

      ################################################################

      class HelperMethod < BooleanMethod
        def initialize(subject_method, method)
          super

          @controller = 'controller'
        end
      end
    end
  end
end

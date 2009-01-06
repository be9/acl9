require File.join(File.dirname(__FILE__), 'dsl_base')

module Acl9
  class AccessDenied < StandardError; end
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

        def _controller_ref
          @controller ? "#{@controller}." : ''
        end
      end

      class FilterLambda < BaseGenerator
        def initialize(subject_method)
          super

          @controller = 'controller'
        end

        def install_on(controller_class, options)
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
      
      class FilterMethod < BaseGenerator
        def initialize(subject_method, method_name)
          super

          @method_name = method_name
          @controller = nil
        end
        
        def install_on(controller_class, options)
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
      
      class BooleanMethod < FilterMethod
        def install_on(controller_class, *_)
          _add_method(controller_class)
        end

        protected 
        
        def to_method_code
          <<-RUBY
            def #{@method_name}(options = {})
              #{allowance_expression}
            end
          RUBY
        end

        def _object_ref(object)
          "(options[:#{object}] || #{super})"
        end
      end
    end
  end
end

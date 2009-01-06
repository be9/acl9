require File.join(File.dirname(__FILE__), 'dsl_base')

module Acl9
  class AccessDenied < StandardError; end
  class FilterSyntaxError < StandardError; end

  module Dsl
    module Generators

      class FilterLambda < Acl9::Dsl::Base
        def initialize(subject_method)
          super
          @subject_method = subject_method
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

        protected 
        
        def _access_denied
          "raise Acl9::AccessDenied"
        end

        def _subject_ref
          "controller.send(:#{@subject_method})"
        end

        def _object_ref(object)
          "controller.instance_variable_get('@#{object}')"
        end

        def _action_ref
          "controller.action_name"
        end
      end
      
      class FilterMethod < Acl9::Dsl::Base
        def initialize(subject_method, method_name)
          super
          @subject_method = subject_method
          @method_name = method_name
        end
        
        def install_on(controller_class, options)
          code = self.to_method_code
          controller_class.send(:class_eval, code)
          controller_class.send(:before_filter, @method_name, options)
        
        rescue SyntaxError
          raise FilterSyntaxError, code
        end
        
        def to_method_code
          <<-RUBY
            def #{@method_name}
              unless #{allowance_expression}; #{_access_denied}; end
            end
          RUBY
        end

        protected 
        
        def _access_denied
          "raise Acl9::AccessDenied"
        end

        def _subject_ref
          "send(:#{@subject_method})"
        end

        def _object_ref(object)
          "instance_variable_get('@#{object}')"
        end

        def _action_ref
          "action_name"
        end
      end
      
      class BooleanMethod < Acl9::Dsl::Base
        def initialize(subject_method, method_name)
          super
          @subject_method = subject_method
          @method_name = method_name
        end
        
        def install_on(controller_class, *_)
          code = self.to_method_code
          controller_class.send(:class_eval, code)
        
        rescue SyntaxError
          raise FilterSyntaxError, code
        end
        
        def to_method_code
          <<-RUBY
            def #{@method_name}(options = {})
              #{allowance_expression}
            end
          RUBY
        end

        protected 
        
        def _access_denied
          "raise Acl9::AccessDenied"
        end

        def _subject_ref
          "send(:#{@subject_method})"
        end

        def _object_ref(object)
          "(options[:#{object}] || instance_variable_get('@#{object}'))"
        end

        def _action_ref
          "action_name"
        end
      end
    end
  end
end

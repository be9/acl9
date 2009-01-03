require 'set'

module Acl9
  class AccessDenied < Exception; end
  class FilterSyntaxError < Exception; end

  class FilterProducer
    attr_reader :allows, :denys

    def initialize(subject_method)
      @subject_method = subject_method
      @default_action = nil
      @allows = []
      @denys = []

      @subject = "controller.send(:#{subject_method})"
    end

    def acl(&acl_block)
      self.instance_eval(&acl_block)
    end

    def to_s
      _allowance_check_expression
    end

    def to_proc
      code = <<-RUBY
        lambda do |controller|
          unless #{self.to_s}
            raise Acl9::AccessDenied
          end
        end
      RUBY
      
      self.instance_eval(code, __FILE__, __LINE__)
    rescue SyntaxError
      raise FilterSyntaxError, code
    end

    def to_method_code(method_name, filter = true)
      body = if filter
               "unless #{self.to_s}; raise Acl9::AccessDenied; end"
             else
               self.to_s
             end

      <<-RUBY
        def #{method_name}
          controller = self
          #{body}
        end
      RUBY
    end

    def default_action
      @default_action.nil? ? :deny : @default_action
    end

    protected

    def default(default_action)
      raise ArgumentError, "default can only be called once in access_control block" if @default_action

      unless [:allow, :deny].include? default_action
        raise ArgumentError, "invalid value for default (can be :allow or :deny)"
      end

      @default_action = default_action
    end

    def allow(*args)
      @current_rule = :allow
      _parse_and_add_rule(*args)
    end
    
    def deny(*args)
      @current_rule = :deny
      _parse_and_add_rule(*args)
    end

    def actions(*args, &block)
      raise ArgumentError, "actions should receive at least 1 action as argument" if args.size < 1    
  
      subsidiary = FilterProducer.new(@subject_method)

      class <<subsidiary
        def actions(*args)
          raise ArgumentError, "You cannot use actions inside another actions block"  
        end

        def default(*args)
          raise ArgumentError, "You cannot use default inside an actions block"  
        end

        def _set_action_clause(to, except)
          raise ArgumentError, "You cannot use :to/:except inside actions block" if to || except
        end
      end

      subsidiary.acl(&block)

      action_check = _action_check_expression(args)
 
      squash = lambda do |rules|
        _either_of(rules) + ' && ' + action_check
      end

      @allows << squash.call(subsidiary.allows) if subsidiary.allows.size > 0
      @denys  << squash.call(subsidiary.denys)  if subsidiary.denys.size > 0
    end

    alias action actions

    def anonymous
      nil
    end
    
    def all
      true
    end

    def logged_in
      false
    end

    private

    def _parse_and_add_rule(*args)
      options = if args.last.is_a? Hash
                  args.pop
                else
                  {}
                end

      _set_action_clause(options.delete(:to), options.delete(:except))

      object = _role_object(options)
        
      role_checks = args.map do |who|
        case who
        when nil   then "#{@subject}.nil?"    # anonymous
        when false then "!#{@subject}.nil?"   # logged_in
        when true  then "true"                # all
        else
          "!#{@subject}.nil? && #{@subject}.has_role?('#{who.to_s.singularize}', #{object})"
        end
      end

      _add_rule case role_checks.size
                when 0
                  raise ArgumentError, "allow/deny should have at least 1 argument"
                when 1 then role_checks.first
                else
                  _either_of(role_checks)
                end
    end

    def _either_of(exprs)
      exprs.map { |expr| "(#{expr})" }.join(' || ')
    end

    def _add_rule(what)
      what = "(#{what}) && #{@action_clause}" if @action_clause

      (@current_rule == :allow ? @allows : @denys) << what
    end

    def _set_action_clause(to, except)
      raise ArgumentError, "both :to and :except cannot be specified in the rule" if to && except

      @action_clause = nil

      action_list = to || except
      return unless action_list

      expr = _action_check_expression(action_list)
      
      @action_clause = if to
                         "#{expr}"
                       else
                         "!#{expr}"
                       end
    end
   
    def _action_check_expression(action_list)
      unless action_list.is_a?(Array)
        action_list = [ action_list.to_s ]
      end

      case action_list.size
      when 0 then "true"
      when 1 then "(controller.action_name == '#{action_list.first}')"
      else
        set_of_actions = "Set.new([" + action_list.map { |act| "'#{act}'"}.join(',')  + "])"

        "#{set_of_actions}.include?(controller.action_name)" 
      end
    end

    VALID_PREPOSITIONS = %w(of for in on at by).freeze unless defined? VALID_PREPOSITIONS

    def _role_object(options)
      object = nil

      VALID_PREPOSITIONS.each do |prep|
        if options[prep.to_sym]
          raise ArgumentError, "You may only use one preposition to specify object" if object

          object = options[prep.to_sym]
        end
      end

      case object
      when Class
        object.to_s
      when Symbol
        "controller.instance_variable_get('@#{object}')"
      when nil
        "nil"
      else
        raise ArgumentError, "object specified by preposition can only be a Class or a Symbol"
      end
    end 

    def _allowance_check_expression
      allowed_expr = if @allows.size > 0
                       @allows.map { |clause| "(#{clause})" }.join(' || ')
                     else
                       "false"
                     end

      not_denied_expr = if @denys.size > 0
                          @denys.map { |clause| "!(#{clause})" }.join(' && ')
                        else
                          "true"
                        end

      [allowed_expr, not_denied_expr].
        map { |expr| "(#{expr})" }.
        join(default_action == :deny ? ' && ' : ' || ')
    end
  end
end

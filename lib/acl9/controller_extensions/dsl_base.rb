module Acl9
  module Dsl
    class Base
      attr_reader :allows, :denys

      def initialize(*args)
        @default_action = nil

        @allows = []
        @denys = []

        @original_args = args
      end

      def acl_block!(&acl_block)
        instance_eval(&acl_block)
      end

      def default_action
        if @default_action.nil? then :deny else @default_action end
      end

      def allowance_expression
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

      alias to_s allowance_expression

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

        subsidiary = self.class.new(*@original_args)

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

        subsidiary.acl_block!(&block)

        action_check = _action_check_expression(args)

        squash = lambda do |rules|
          action_check + ' && ' + _either_of(rules)
        end

        @allows << squash.call(subsidiary.allows) if subsidiary.allows.size > 0
        @denys  << squash.call(subsidiary.denys)  if subsidiary.denys.size > 0
      end

      alias action actions

      def logged_in; false end
      def anonymous; nil   end
      def all;       true  end

      alias everyone all
      alias everybody all
      alias anyone all

      def _parse_and_add_rule(*args)
        options = args.extract_options!

        _set_action_clause(options.delete(:to), options.delete(:except))

        object = _role_object(options)

        role_checks = args.map do |who|
          case who
          when anonymous() then "#{_subject_ref}.nil?"
          when logged_in() then "!#{_subject_ref}.nil?"
          when all()       then "true"
          else
            "!#{_subject_ref}.nil? && #{_subject_ref}.has_role?('#{who.to_s.singularize}', #{object})"
          end
        end

        [:if, :unless].each do |cond|
          val = options[cond]
          raise ArgumentError, "#{cond} option must be a Symbol" if val && !val.is_a?(Symbol)
        end

        condition = [
          (_method_ref(options[:if]) if options[:if]),
          ("!#{_method_ref(options[:unless])}" if options[:unless])
        ].compact.join(' && ')

        condition = nil if condition.blank?

        _add_rule(case role_checks.size
                  when 0
                    raise ArgumentError, "allow/deny should have at least 1 argument"
                  when 1 then role_checks.first
                  else
                    _either_of(role_checks)
                  end, condition)
      end

      def _either_of(exprs)
        clause = exprs.map { |expr| "(#{expr})" }.join(' || ')
        return "(#{clause})"
      end

      def _add_rule(what, condition)
        anded = [what] + [@action_clause, condition].compact
        anded[0] = "(#{anded[0]})" if anded.size > 1

        (@current_rule == :allow ? @allows : @denys) << anded.join(' && ')
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
        when 1 then "(#{_action_ref} == '#{action_list.first}')"
        else
          set_of_actions = "Set.new([" + action_list.map { |act| "'#{act}'"}.join(',')  + "])"

          "#{set_of_actions}.include?(#{_action_ref})"
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
          _object_ref object
        when nil
          "nil"
        else
          raise ArgumentError, "object specified by preposition can only be a Class or a Symbol"
        end
      end

      def _subject_ref
        raise
      end

      def _object_ref(object)
        raise
      end

      def _action_ref
        raise
      end

      def _method_ref(method)
        raise
      end
    end
  end
end

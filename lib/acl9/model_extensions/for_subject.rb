module Acl9
  module ModelExtensions
    module ForSubject
      ##
      # Role check.
      #
      # There is a global option, +Acl9.config[:protect_global_roles]+, which governs
      # this method behavior.
      #
      # If protect_global_roles is +false+, an object role is automatically counted
      # as global role. E.g.
      #
      #   Acl9.config[:protect_global_roles] = false
      #   user.has_role!(:manager, @foo)
      #   user.has_role?(:manager, @foo)  # => true
      #   user.has_role?(:manager)        # => true
      #
      # In this case manager is anyone who "manages" at least one object.
      #
      # However, if protect_global_roles option set to +true+, you'll need to 
      # explicitly grant global role with same name.
      #
      #   Acl9.config[:protect_global_roles] = true
      #   user.has_role!(:manager, @foo)
      #   user.has_role?(:manager)        # => false
      #   user.has_role!(:manager)
      #   user.has_role?(:manager)        # => true
      #
      # protect_global_roles option is +false+ by default as for now, but this 
      # may change in future!
      #
      # @return [Boolean] Whether +self+ has a role +role_name+ on +object+.
      # @param [Symbol,String] role_name Role name
      # @param [Object] object Object to query a role on
      #
      # @see Acl9::ModelExtensions::Object#accepts_role?
      def has_role?(role_name, object = nil)
        !! if object.nil? && !::Acl9.config[:protect_global_roles]
          self.role_objects.find_by_name(role_name.to_s) ||
          self.role_objects.member?(get_role(role_name, nil))
        else
          role = get_role(role_name, object)
          role && self.role_objects.exists?(role.id)
        end
      end

      ##
      # Add specified role on +object+ to +self+.
      #
      # @param [Symbol,String] role_name Role name
      # @param [Object] object Object to add a role for
      # @see Acl9::ModelExtensions::Object#accepts_role!
      def has_role!(role_name, object = nil)
        role = get_role(role_name, object)

        if role.nil?
          role_attrs = case object
                       when Class then { :authorizable_type => object.to_s }
                       when nil   then {}
                       else            { :authorizable => object }
                       end.merge(      { :name => role_name.to_s })

          role = self._auth_role_class.create(role_attrs)
        end

        self.role_objects << role if role && !self.role_objects.exists?(role.id)
      end

      ##
      # Free +self+ from a specified role on +object+.
      #
      # @param [Symbol,String] role_name Role name
      # @param [Object] object Object to remove a role on
      # @see Acl9::ModelExtensions::Object#accepts_no_role!
      def has_no_role!(role_name, object = nil)
        delete_role(get_role(role_name, object))
      end

      ##
      # Are there any roles for +self+ on +object+?
      #
      # @param [Object] object Object to query roles
      # @return [Boolean] Returns true if +self+ has any roles on +object+.
      # @see Acl9::ModelExtensions::Object#accepts_roles_by?
      def has_roles_for?(object)
        !!self.role_objects.detect(&role_selecting_lambda(object))
      end

      alias :has_role_for? :has_roles_for?

      ##
      # Which roles does +self+ have on +object+?
      #
      # @return [Array<Role>] Role instances, associated both with +self+ and +object+
      # @param [Object] object Object to query roles
      # @see Acl9::ModelExtensions::Object#accepted_roles_by
      # @example
      #   user = User.find(...)
      #   product = Product.find(...)
      #
      #   user.roles_for(product).map(&:name).sort  #=> role names in alphabetical order
      def roles_for(object)
        self.role_objects.select(&role_selecting_lambda(object))
      end

      ##
      # Unassign any roles on +object+ from +self+.
      #
      # @param [Object,nil] object Object to unassign roles for. +nil+ means unassign global roles.
      def has_no_roles_for!(object = nil)
        roles_for(object).each { |role| delete_role(role) }
      end

      ##
      # Unassign all roles from +self+.
      def has_no_roles!
        # for some reason simple
        #
        #   self.roles.each { |role| delete_role(role) }
        #
        # doesn't work. seems like a bug in ActiveRecord
        self.role_objects.map(&:id).each do |role_id|
          delete_role self._auth_role_class.find(role_id)
        end
      end

      private

      def role_selecting_lambda(object)
        case object
        when Class
          lambda { |role| role.authorizable_type == object.to_s }
        when nil
          lambda { |role| role.authorizable.nil? }
        else
          lambda do |role|
            role.authorizable_type == object.class.base_class.to_s && role.authorizable == object
          end
        end
      end

      def get_role(role_name, object)
        role_name = role_name.to_s

        cond = case object
               when Class
                 [ 'name = ? and authorizable_type = ? and authorizable_id IS NULL', role_name, object.to_s ]
               when nil
                 [ 'name = ? and authorizable_type IS NULL and authorizable_id IS NULL', role_name ]
               else
                 [
                   'name = ? and authorizable_type = ? and authorizable_id = ?',
                   role_name, object.class.base_class.to_s, object.id
                 ]
               end

        self._auth_role_class.first :conditions => cond
      end

      def delete_role(role)
        if role
          self.role_objects.delete role
          if role.send(self._auth_subject_class_name.demodulize.tableize).empty?
            role.destroy unless role.respond_to?(:system?) && role.system?
          end
        end
      end
      
      protected

      def _auth_role_class
        self.class._auth_role_class_name.constantize
      end
      
      def _auth_role_assoc
      	self.class._auth_role_assoc_name
      end

      def role_objects
      	send(self._auth_role_assoc)
      end

    end
  end
end

module Acl9
  module ModelExtensions
    module Subject
      def has_role?(role_name, object = nil)
        !! if object.nil?
          self.roles.find_by_name(role_name.to_s) ||
          self.roles.member?(get_role(role_name, nil))
        else
          role = get_role(role_name, object)
          role && self.roles.exists?(role.id)
        end
      end

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

        self.roles << role if role && !self.roles.exists?( role.id )
      end

      def has_no_role!(role_name, object = nil)
        delete_role(get_role(role_name, object))
      end

      def has_roles_for?(object)
        !!self.roles.detect(&role_selecting_lambda(object))
      end

      alias :has_role_for? :has_roles_for?

      def roles_for(object)
        self.roles.select(&role_selecting_lambda(object))
      end

      def has_no_roles_for!(object = nil)
        roles_for(object).each { |role| delete_role(role) }
      end

      def has_no_roles!
        # for some reason simple 
        #
        #   self.roles.each { |role| delete_role(role) }
        #
        # doesn't work. seems like a bug in ActiveRecord
        self.roles.map(&:id).each do |role_id|
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
          self.roles.delete role

          role.destroy if role.users.empty?
        end
      end

      protected

      def _auth_role_class
        self.class._auth_role_class_name.constantize
      end
    end
  end
end

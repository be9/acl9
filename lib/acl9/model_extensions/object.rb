module Acl9
  module ModelExtensions
    module Object
      def accepts_role?(role_name, subject)
        subject.has_role? role_name, self
      end

      def accepts_role!(role_name, subject)
        subject.has_role! role_name, self
      end

      def accepts_no_role!(role_name, subject)
        subject.has_no_role! role_name, self
      end

      def accepts_roles_by?(subject)
        subject.has_roles_for? self
      end

      alias :accepts_role_by? :accepts_roles_by?

      def accepted_roles_by(subject)
        subject.roles_for self
      end
    end
  end
end

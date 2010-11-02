module Acl9
  module Helpers
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def access_control(method, opts = {}, &block)
        subject_method = opts.delete(:subject_method) || Acl9::config[:default_subject_method]
        raise ArgumentError, "Block must be supplied to access_control" unless block

        generator = Acl9::Dsl::Generators::HelperMethod.new(subject_method, method)

        generator.acl_block!(&block)
        generator.install_on(self, opts)
      end

    end

    # Usage:
    #
    #     <%=show_to(:owner, :supervisor, :of => :account) do %>
    #       <%= 'hello' %>
    #     <% end %>
    #
    def show_to(*args, &block)
      user = send(Acl9.config[:default_subject_method])
      return if user.nil?

      has_any = false

      if args.last.is_a?(Hash)
        an_obj  = args.pop.values.first
        has_any = args.detect { |role| user.has_role?(role, an_obj) }
      else
        has_any = args.detect { |role| user.has_role?(role) }
      end

      has_any ? capture(&block) : nil
    end
  end
end

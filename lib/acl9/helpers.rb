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
  end
end

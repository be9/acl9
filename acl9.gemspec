# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acl9}
  s.version = "0.9.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["oleg dashevskii"]
  s.date = %q{2009-02-27}
  s.description = %q{Yet another role-based authorization system for Rails with a nice DSL for access control lists.}
  s.email = %q{olegdashevskii@gmail.com}
  s.files = ["CHANGELOG.textile", "MIT-LICENSE", "Rakefile", "README.textile", "TODO", "VERSION.yml", "lib/acl9/config.rb", "lib/acl9/controller_extensions/dsl_base.rb", "lib/acl9/controller_extensions/generators.rb", "lib/acl9/controller_extensions.rb", "lib/acl9/helpers.rb", "lib/acl9/model_extensions/object.rb", "lib/acl9/model_extensions/subject.rb", "lib/acl9/model_extensions.rb", "lib/acl9.rb", "spec/access_control_spec.rb", "spec/controllers.rb", "spec/db/schema.rb", "spec/dsl_base_spec.rb", "spec/helpers_spec.rb", "spec/models.rb", "spec/roles_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/be9/acl9}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Yet another role-based authorization system for Rails with a nice DSL for access control lists.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.1.12"])
      s.add_development_dependency(%q<rspec-rails>, [">= 1.1.12"])
    else
      s.add_dependency(%q<rspec>, [">= 1.1.12"])
      s.add_dependency(%q<rspec-rails>, [">= 1.1.12"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.1.12"])
    s.add_dependency(%q<rspec-rails>, [">= 1.1.12"])
  end
end

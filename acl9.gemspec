# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acl9}
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["oleg dashevskii"]
  s.date = %q{2009-05-03}
  s.description = %q{Role-based authorization system for Rails with a nice DSL for access control lists}
  s.email = %q{olegdashevskii@gmail.com}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    "CHANGELOG.textile",
    "MIT-LICENSE",
    "README.textile",
    "Rakefile",
    "TODO",
    "VERSION.yml",
    "lib/acl9.rb",
    "lib/acl9/config.rb",
    "lib/acl9/controller_extensions.rb",
    "lib/acl9/controller_extensions/dsl_base.rb",
    "lib/acl9/controller_extensions/generators.rb",
    "lib/acl9/helpers.rb",
    "lib/acl9/model_extensions.rb",
    "lib/acl9/model_extensions/object.rb",
    "lib/acl9/model_extensions/subject.rb",
    "test/access_control_test.rb",
    "test/dsl_base_test.rb",
    "test/helpers_test.rb",
    "test/roles_test.rb",
    "test/support/controllers.rb",
    "test/support/models.rb",
    "test/support/schema.rb",
    "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/be9/acl9}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Yet another role-based authorization system for Rails}
  s.test_files = [
    "test/helpers_test.rb",
    "test/support/schema.rb",
    "test/support/models.rb",
    "test/support/controllers.rb",
    "test/dsl_base_test.rb",
    "test/access_control_test.rb",
    "test/test_helper.rb",
    "test/roles_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<jeremymcanally-context>, [">= 0.5.5"])
      s.add_development_dependency(%q<jnunemaker-matchy>, [">= 0.4.0"])
    else
      s.add_dependency(%q<jeremymcanally-context>, [">= 0.5.5"])
      s.add_dependency(%q<jnunemaker-matchy>, [">= 0.4.0"])
    end
  else
    s.add_dependency(%q<jeremymcanally-context>, [">= 0.5.5"])
    s.add_dependency(%q<jnunemaker-matchy>, [">= 0.4.0"])
  end
end

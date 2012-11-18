# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "deprecated"
  s.version = "3.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Erik Hollensbe"]
  s.date = "2012-09-29"
  s.email = "erik@hollensbe.org"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "deprecated"
  s.rubygems_version = "1.8.24"
  s.summary = "An easy way to handle deprecating and conditionally running deprecated code"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>, [">= 0"])
    else
      s.add_dependency(%q<test-unit>, [">= 0"])
    end
  else
    s.add_dependency(%q<test-unit>, [">= 0"])
  end
end

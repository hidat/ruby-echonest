# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bassnode-ruby-echonest}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["youpy", "bassnode"]
  s.date = %q{2011-04-24}
  s.description = %q{An Ruby interface for Echo Nest Developer API}
  s.summary = %q{An Ruby interface for Echo Nest Developer API}
  s.email = %q{youpy@buycheapviagraonlinenow.com}
  s.homepage = %q{http://github.com/bassnode/ruby-echonest}
  s.rubyforge_project = %q{bassnode-ruby-echonest}
  s.rubygems_version = %q{1.3.6}
  s.platform = Gem::Platform::RUBY

  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.rdoc_options = ["--title", "ruby-echonest documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")


  s.add_dependency(%q<libxml-ruby>, [">= 0"])
  s.add_dependency(%q<httpclient>, [">= 0"])
  s.add_dependency(%q<hashie>, [">= 0"])
  s.add_development_dependency('rspec')
end

# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{giant_bomb}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jon Maddox"]
  s.date = %q{2010-02-03}
  s.description = %q{Simple library to talkto the awesome GiantBomb data}
  s.email = %q{jon@fanzter.com}
  s.extra_rdoc_files = ["LICENSE", "README.textile"]
  s.files = [".document", ".gitignore", "LICENSE", "README.textile", "Rakefile", "VERSION", "giant_bomb.gemspec", "lib/giant_bomb.rb", "lib/giant_bomb/attributes.rb", "lib/giant_bomb/core_extensions.rb", "lib/giant_bomb/developer.rb", "lib/giant_bomb/game.rb", "lib/giant_bomb/genre.rb", "lib/giant_bomb/httparty_icebox.rb", "lib/giant_bomb/publisher.rb", "lib/giant_bomb/search.rb", "test/fixtures/get_info.json", "test/fixtures/mega_man_x.json", "test/fixtures/search.json", "test/fixtures/sketchy_results.json", "test/game_test.rb", "test/giant_bomb_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/fanzter/giant_bomb}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Simple library to talk to the awesome GiantBomb data}
  s.test_files = ["test/game_test.rb", "test/giant_bomb_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.3"])
      s.add_development_dependency(%q<fakeweb>, [">= 0"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0.4.3"])
      s.add_dependency(%q<fakeweb>, [">= 0"])
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0.4.3"])
    s.add_dependency(%q<fakeweb>, [">= 0"])
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end

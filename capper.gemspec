Gem::Specification.new do |s|
  s.name = "capper"
  s.version = "0.3.1"
  s.platform = Gem::Platform::RUBY
  s.licenses = ["MIT"]
  s.authors = ["Benedikt Böhm"]
  s.email = ["bb@xnull.de"]
  s.homepage = "http://github.com/hollow/capper"
  s.summary = %q{Capistrano is a collection of opinionated Capistrano recipes}
  s.description = %q{Capistrano is a collection of opinionated Capistrano recipes}

  s.add_dependency "erubis"
  s.add_dependency "capistrano"
  s.add_dependency "capistrano_colors"

  s.add_development_dependency "bundler", "~> 1.0.0"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths    = ["lib"]
  s.extra_rdoc_files = ["LICENSE", "README.md"]
end

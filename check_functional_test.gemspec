# -*- encoding: utf-8 -*-
require File.expand_path('../lib/check_functional_test/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["david"]
  gem.email         = ["david@baoleihang.com"]
  gem.description   = %q{TOdfsdfO: Write a gem descriptidfn}
  gem.summary       = %q{TdfDO: Wsdfrite a gem summsdfary}
  gem.homepage      = "https://github.com/davidqin/check_functional_test"

  gem.files         = `git ls-files`.split($\)
#  gem.executables   = %w( check_functional_test )#gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "check_functional_test"
  gem.require_paths = ["lib"]
  gem.version       = CheckFunctionalTest::VERSION

  gem.add_dependency "ansi", "~> 1.4.3"
end

require 'check_functional_test'
require 'rails'
module CheckFunctionalTest
  class Railtie < Rails::Railtie
    railtie_name :check_functional_test

    rake_tasks do
      load "tasks/check_functional_test.rake"
    end
  end
end

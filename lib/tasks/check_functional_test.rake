namespace :func do
  namespace :test do

    desc 'check you functional test is completed without missing'
    task :check => :environment do
      CheckFunctionalTest::Check.new.check
    end

    desc 'generate your missing functional test controllers and actions'
    task :repire do
      CheckFunctionalTest::Repire.new(CheckFunctionalTest::Check.new)
    end
  end
end
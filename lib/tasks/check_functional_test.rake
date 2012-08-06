namespace :func do
  namespace :test do

    desc 'check you functional test is completed without missing'
    task :check => :environment do
      CheckFunctionalTest::CheckFunctionalTest.new.check
    end

    desc 'generate your missing functional test controllers and actions'
    task :repire do
      puts "the rake task did something"
    end

  end
end
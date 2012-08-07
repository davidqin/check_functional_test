namespace :func do
  namespace :test do

    desc 'check you functional test is completed without missing'
    task :check => :environment do
      CheckFunctionalTest::Check.new.check_and_report
    end

    desc 'generate your missing functional test controllers and actions'
    task :repair => :environment do
      CheckFunctionalTest::Repair.new(CheckFunctionalTest::Check.new.check)
    end
  end
end

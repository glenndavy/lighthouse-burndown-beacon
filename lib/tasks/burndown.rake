namespace :burndown do
  desc "Add fake stats in to dev" 
  task :gimme_fake_stats => :environment do
    if RAILS_ENV['development']
      (1..100).collect.reverse.each do |i|
        dt = Date.today - i 
        DailyStat.create!(
                  :when => dt, 
                  :total_points => 10.0 + (i % 10 * 1.5),
                  :ticket_count => 5 + i % 5
                  )
      end
    end
  end
  
  desc "delete development stats" 
  task :delete_stats => :environment do
    if RAILS_ENV['development']
      DailyStat.delete_all
    end
  end
end

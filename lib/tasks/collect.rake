namespace :taxes do
  desc "Do monthly tax collection"
  task :collect => :environment do
    puts "Collecting monthly taxes..."
    Tax.active.each do |tax|
      next unless tax.meets_goal
      puts "Doing #{tax.name}"
      tax.pledges.active.find_each do |pledge|
        puts "  #{pledge.user.name} for $#{pledge.amount}"
        pledge.collect
      end
    end
    puts "Done"
  end
end

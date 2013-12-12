namespace :taxes do

  desc "Do monthly tax collection for all taxes, no minimum"
  task :collect => :environment do
    puts "Collecting monthly taxes..."
    Pledge.collect_all
    puts "Done!"
  end

  desc "Transfer funds to bank accounts"
  task :transfer => :environment do
    puts "Transferring funds..."
    Transfer.pending.each do |t|
      t.complete_transfer
    end
    puts "Done!"
  end

  desc "Do monthly tax collection for those that surpass their minimum pledge amount"
  task :collect_succeeded => :environment do
    puts "Collecting monthly taxes..."
    Tax.active.each do |tax|
      puts "Doing #{tax.name}"
      tax.pledges.active.find_each do |pledge|
        puts "  #{pledge.user.name} for $#{pledge.amount}"
        pledge.collect
      end
    end
    puts "Done"
  end

end


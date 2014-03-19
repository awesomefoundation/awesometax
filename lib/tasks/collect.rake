namespace :taxes do

  desc "Do monthly tax collection for all taxes, no minimum"
  task :collect => :environment do
    puts "Collecting monthly taxes..."
    if (Time.new.day != 1) ||
      (Transaction.count == 0) ||
      (Date.today.month == Transaction.last.created_at.month)
      puts "There has already been a collection recently. No can do. This is a safeguard that's very easy to override if you mean it."
    else
      Pledge.collect_all
    end
    puts "Done!"
  end

  desc "Run collection even if it has been run in last month"
  task :collect_override => :environment do
    puts "Collecting monthly taxes even if they have been recently collected..."
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

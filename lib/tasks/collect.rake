namespace :lovetax do
  desc "Do monthly tax collection"
    task :collect => :environment do
    puts "Collecting monthly taxes..."
    Pledge.collect_all
    puts "Done"
  end
end

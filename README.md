awesometax
==========

The Awesometax crowdfunding platform.


Configuration
-------------

Edit config/database.yml as needed for the MySQL config.

We're set up for Apache + Passenger with RVM and Ruby 1.9.3. I have a .rvmrc that specifies the gemset "rails30."


Monthly collection
------------------
We have rake tasks that run through all current taxes, do the Stripe transactions, and send email notifications to the affected users.

    bundle exec rake taxes:collect --trace

To automate this, I have a script called collect_taxes.sh. It emails the output of the rake script to me. Of course the particulars here will vary depending on your server setup:

    #!/bin/bash
    RAILS_ENV=production
    PATH=$PATH:$HOME/.rvm/bin
    cd /var/www/awesometax_prod
    rvm 1.9.3@rails30 do rake taxes:collect | mail -s "[AwesomeTax] Monthly collection" your@emailaddress.com

I set up a cron job to do this at noon on the 8th of every month. Run "crontab -e" and add this line:

    0 12 8 * *   /home/youruser/collect_taxes.sh

#!/bin/bash
export GEM_HOME="$HOME/.gems"
export GEM_PATH="$GEM_HOME:/usr/lib/ruby/gems/1.8"
export PATH="$PATH:$GEM_HOME/bin:$HOME/usr/local/bin"
export RAILS_ENV="staging"

cd ~/lovetax_stage
bundle exec rake lovetax:collect --trace


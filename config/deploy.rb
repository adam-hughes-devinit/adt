set :application, "adt"
set :scm, :git
set :repository,  "git@github.com:rmosolgo/adt.git"
# Really should be "adt_user"

set :user, "rmosolgo"


server "china.aiddata.org", :app, :primary => true
set :deploy_to, "var/www/adt"
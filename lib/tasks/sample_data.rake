namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
  end
end


def make_users
  admin = User.create!(name: "rmosolgo",
               email: "rmosolgo@aiddata.org",
               password: "foobar",
               password_confirmation: "foobar")
  #admin.toggle!(:admin)
  
  99.times do |n|
    name  = Faker::Name.name
    email = "#{name}@aiddata.org"
    password  = "password"
    User.create!(name: name,
                 email: email,
                 password: password,
                 password_confirmation: password)
  end
end

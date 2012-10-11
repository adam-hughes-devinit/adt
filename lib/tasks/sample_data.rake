namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    make_countries
    make_organizations
    make_supporting_data
    
    make_users
    make_projects

  end
end


def make_supporting_data
  Status.create(name: 'Completed', iati_code: 5)
  Verified.create(name: 'Suspicious')
  Tied.create(name: 'Partially Tied', iati_code: 5)
  OdaLike.create(name: 'ODA-Like')
  FlowType.create(name: 'Grants', iati_code: 10)
  Sector.create(name: 'Education')
end

def make_countries
  data =  [["China", "CHN"], ["Venezuela", "VNZ"], ["Cote D'Ivoire", "CIV"]]
  data.each do |d|
    Country.create(name: d[0], iso3:d[1])
  end
end

def make_organizations
    Organization.create(name: 'AidData', description: 'Tracking Development Finance')
  10.times do
    Organization.create(
      name: Faker::Company.name,
      description: Faker::Company.catch_phrase)
  end
end

def make_users
  admin = User.create!(name: "rmosolgo",
               email: "rmosolgo@aiddata.org",
               password: "foobar",
               password_confirmation: "foobar",
               owner: Organization.first )
  #admin.toggle!(:admin)
  
  99.times do |n|
    name  = Faker::Name.name
    email = "example#{(n+1).to_s}@aiddata.org"
    password  = "password"
    User.create!(name: name,
                 email: email,
                 password: password,
                 password_confirmation: password,
                 owner: Organization.first)
  end
end

def make_currencies
  6.times do 
    name = Faker::Lorem.words[0]
    country = Faker::Address.country
    c = Currency.create!(name: "#{country} #{name}", 
                        iso3: name[0..2].upcase )
  end
end
  


def make_projects
  100.times do |p|
    p = Project.new
    p.title = Faker::Company.bs.capitalize
    p.description = Faker::Lorem.paragraph
    p.capacity = Faker::Lorem.sentence
    p.year = rand(2000..2011)
    p.is_commercial = true
    p.sector_comment = Faker::Company.catch_phrase

    p.start_actual = 5.years.ago
    p.start_planned = 6.years.ago
    p.end_actual = 1.year.ago
    p.end_planned = 2.years.ago

    p.oda_like = OdaLike.first
    p.tied = Tied.first
    p.sector = Sector.first
    p.flow_type = FlowType.first
    p.status = Status.first
    p.verified = Verified.first

    p.donor = Country.first
    p.owner = Organization.find_by_name('AidData')

    p.save
  end

end



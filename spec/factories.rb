Factory.define :comment do |c|
  c.name 'Brad Parks'
  c.email 'bparks@aiddata.org'
  c.content 'Lorem ipsum'
end


Factory.define :status do |s|
  s.name 'Cancelled'
  s.iati_code '5'
end

Factory.define :verified do |v|
  v.name 'Suspicious'
end

Factory.define :oda_like do |o|
  o.name 'OOF-Like'
end
 
Factory.define :flow_type do |f|
  f.name 'Grant'
  f.iati_code 1 #these are bogus numbers
  f.oecd_code 10
  f.aiddata_code 10454
end

Factory.define :tied do |t|
  t.name 'Partially Tied'
  t.iati_code 5
end

Factory.define :sector do |s|
  s.name 'Education'
end

Factory.define :country do |c|
  country_name = Faker::Address.country
  c.name country_name
  c.iso3 country_name[0..2].upcase
end

Factory.define :source_type do |s|
  s.name 'Factiva'
end

Factory.define :document_type do |d|
  d.name "International media report"
end

Factory.define :organization do |o|
  o.name Faker::Company.name
  o.description Faker::Company.catch_phrase
end

Factory.define :role do |r|
  names = ["Implementing", "Funding", "Executing", "Accountable"]
  r.name  names.sample
  r.iati_code rand(1..5)
end

Factory.define :origin do |o|
	names =["Donor", "Recipient"]
	o.name names.sample
end

Factory.define :source do |s|
  s.url 'www.cnn.com'
  s.document_type FactoryGirl.create(:document_type)
  s.source_type FactoryGirl.create(:source_type)
  s.date 1.day.ago
end


#Factory.define :user do |user|
#  user.name                  "rmosolgo"
#	sequence(:email) { |n| "user#{n}@example.com" }
#  user.password              "foobar"
#  user.password_confirmation "foobar"
#  user.owner FactoryGirl.create(:organization)
#end

FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@example.com"
  end

  factory :user do
    email
    name "rmosolgo"
    password "secret"
    password_confirmation "secret"
    owner FactoryGirl.create(:organization)
  end
end

Factory.define :currency do |currency|
  iso3 = ["CNY", "USD", "EUR", "KES", "XAF"].sample
  currency_name = Faker::Lorem.words[0]
  currency.name "#{iso3} #{currency_name.capitalize}"
  currency.iso3 iso3
end

Factory.define :contact do |c|
  c.name "Hu Jintao"
  c.position "President"
  c.organization Organization.first
end

Factory.define :transaction do |transaction|
  transaction.value rand(1000..10000000)
  transaction.currency FactoryGirl.create(:currency)
end


Factory.define :geopolitical do |g|
  subnational_city = Faker::Address.city
  subnational_street = Faker::Address.street_name
  subnational_field = subnational_street+', '+subnational_city
  g.recipient FactoryGirl.create(:country)
  g.subnational subnational_field
  g.percent rand(0..50).round
end

Factory.define :participating_organization do |o|
  o.role  FactoryGirl.create(:role)
  o.organization  FactoryGirl.create(:organization)
end

Factory.define :project do |project|

  project.title "Example project title"
  project.description "Example description of a development project"
  project.active true
  project.start_actual 10.years.ago
  project.start_planned 11.years.ago
  project.end_planned 2.years.ago
  project.end_actual 1.year.ago
  project.year 2002
  project.is_commercial false

  project.status FactoryGirl.create(:status)
  project.verified FactoryGirl.create(:verified)
  # project.oda_like FactoryGirl.create(:oda_like)
  project.flow_type FactoryGirl.create(:flow_type)
  # project.tied FactoryGirl.create(:tied)
  project.sector FactoryGirl.create(:sector)

  project.donor FactoryGirl.create(:country)
  project.owner FactoryGirl.create(:organization)

end


Factory.define :flag_type do |ft|
	ft.name ["Confirm", "Deny", "Challenge", "Dispute", "Applaud"].sample.capitalize
	ft.color ['red', 'blue', 'green', 'yellow'].sample
end

Factory.define :flag do |f|
		f.flag_type FactoryGirl.create(:flag_type)
		f.flaggable_type "Transaction"
		f.flaggable_id FactoryGirl.create(:transaction).id
		f.owner FactoryGirl.create(:user, email: "flag_email#{rand(0..1000000).round}@example.com")
		f.comment 'I have something to say'
		f.source 'www.cnn.com/facts'
end

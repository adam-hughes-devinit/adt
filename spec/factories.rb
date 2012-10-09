Factory.define :user do |user|
  user.name                  "rmosolgo"
  user.email                 "rmosolgo@aiddata.org"
  user.password              "foobar"
  user.password_confirmation "foobar"
end


Factory.define :status do |s|
  s.name 'Cancelled'
  s.iati_code '5'
end

Factory.define :verified do |v|
  v.name 'Suspicious'
end

Factory.define :oda_like do |o|
  o.name 'OOF-like'
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
  project.oda_like FactoryGirl.create(:oda_like)
  project.flow_type FactoryGirl.create(:flow_type)
  project.tied FactoryGirl.create(:tied)
end

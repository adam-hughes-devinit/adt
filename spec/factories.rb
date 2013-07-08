# encoding: UTF-8
FactoryGirl.define do

  factory :status do |s|
    s.name 'Cancelled'
    s.iati_code '5'
  end

  factory :verified do |v|
    v.name 'Suspicious'
  end

  factory :oda_like do |o|
    o.name 'OOF-Like'
  end
  
  factory :flow_type do |f|
    f.name 'Grant'
    f.iati_code 1 #these are bogus numbers
    f.oecd_code 10
    f.aiddata_code 10454
  end

  factory :tied do |t|
    t.name 'Partially Tied'
    t.iati_code 5
  end

  factory :crs_sector do |s|
    s.name 'Education'
  end

  factory :country do |c|
    country_name = Faker::Address.country
    c.name country_name
    c.iso3 country_name[0..2].upcase
  end

  factory :source_type do |s|
    s.name 'Factiva'
  end

  factory :document_type do |d|
    d.name "International media report"
  end

  factory :organization_type do |ot|
    ot.name Faker::Company.name
  end
  
  factory :organization do |o|
    o.name Faker::Company.name
    o.description Faker::Company.catch_phrase
  end

  factory :role do |r|
    names = ["Implementing", "Funding", "Executing", "Accountable"]
    r.name  names.sample
    r.iati_code Random.rand(1..5)
  end

  factory :origin do |o|
    names =["Donor", "Recipient"]
    o.name names.sample
  end

  factory :source do |s|
    s.url 'www.cnn.com'
    s.document_type FactoryGirl.create(:document_type)
    s.source_type FactoryGirl.create(:source_type)
    s.date 1.day.ago
  end

  FactoryGirl.define do
    sequence :email do |n|
      "email#{n}@aiddata.org"
    end

    factory :user do
      email
      name "rmosolgo"
      password "secret123"
      password_confirmation "secret123"
      owner FactoryGirl.create(:organization)

      trait :aiddata do
        owner Organization.find_or_create_by_name("AidData")
      end

    end
  end

  factory :currency do |currency|
    iso3 = ["CNY", "JPY", "EUR", "KES", "XAF"].sample
    currency_name = Faker::Lorem.words[0]
    currency.name "#{iso3} #{currency_name.capitalize}"
    currency.iso3 iso3
  end

  factory :contact do |c|
    c.name "Hu Jintao"
    c.position "President"
    c.organization Organization.first
  end

  factory :transaction do |transaction|
    transaction.value Random.rand(1000..10000000)
    transaction.currency FactoryGirl.create(:currency)
  end


  factory :geopolitical do |g|
    subnational_city = Faker::Address.city
    subnational_street = Faker::Address.street_name
    subnational_field = subnational_street+', '+subnational_city
    g.recipient FactoryGirl.create(:country)
    g.subnational subnational_field
    g.percent 47.0
  end

  factory :participating_organization do |o|
    o.role  FactoryGirl.create(:role)
    o.organization  FactoryGirl.create(:organization)
  end

  factory :project do

    title "Example project title"
    description "Example description of a development project"
    active true
    start_actual 10.years.ago
    start_planned 11.years.ago
    end_planned 2.years.ago
    end_actual 1.year.ago
    year 2002
    is_commercial false

    flow_type FactoryGirl.create(:flow_type)
    crs_sector FactoryGirl.create(:crs_sector)

    donor Country.find_or_create_by_name("China", iso3: "CHN", iso2: "CN")
    owner FactoryGirl.create(:organization)

    trait :aiddata do
      owner Organization.find_or_create_by_name("AidData")
    end

    trait :offic do
      oda_like FactoryGirl.create(:oda_like, )#name: "ODA-like")
      active true
      verified FactoryGirl.create(:verified, name: "Checked")
      status FactoryGirl.create(:status, name: "Pipeline: Pledge")
    end

    
    trait :unoffic do
      oda_like FactoryGirl.create(:oda_like, name: "NGO Aid")
      active true
      verified FactoryGirl.create(:verified, name: "Checked")
      status FactoryGirl.create(:status, name: "Bogus")
    end

    trait :military do
      oda_like FactoryGirl.create(:oda_like, name: "Military")
      active true
      verified FactoryGirl.create(:verified, name: "Checked")
      status FactoryGirl.create(:status, name: "Bogus")
    end

    trait :cancelled do
      status FactoryGirl.create(:status, name: "Cancelled")
      active true
      verified FactoryGirl.create(:verified, name: "Checked")
    end

    trait :sus do
      active true
      verified FactoryGirl.create(:verified, name: "Suspicious")
    end

    trait :inact do
      status FactoryGirl.create(:status, name: "Cancelled")
      active false
    end
  end



  factory :flag_type do |ft|
    ft.name ["Confirm", "Deny", "Challenge", "Dispute", "Applaud"].sample.capitalize
    ft.color ['red', 'blue', 'green', 'yellow'].sample
  end

  factory :flag do |f|
      f.flag_type FactoryGirl.create(:flag_type)
      f.flaggable_type "Project"
      f.flaggable_id FactoryGirl.create(:project).id
      f.owner FactoryGirl.create(:user, email: "flag_email#{Random.rand(0..1000000).round}@example.com")
      f.comment 'I have something to say'
      f.source 'www.cnn.com/facts'
  end

  factory :comment do |c|
    c.name 'Brad Parks'
    c.email 'bparks@aiddata.org'
    c.content 'Lorem ipsum'
    c.project FactoryGirl.create(:project)
  end

  
  FactoryGirl.define do 
    sequence :source_url do |n|
      "http://aiddatachina.org/projects/#{n}"
    end
  
    factory :resource do |r|
      r.title "China in Africa Stuff"
      r.authors "Hu Jintao, Xi Jinping"
      source_url 
      r.resource_type Resource.resource_types.sample
    end
  end

  factory :content do |c|
    c.content_type "Page"
    c.name "meet_the_team"
    c.chinese_name "大家好"
    c.content "# Hey, everyone's here!"
    c.chinese_content "# 大家好"
  end

  factory :loan_type do |l|
    l.name %w{Interest-Free Concessional Commercial}.sample
    l.description Faker::Lorem.words(10).join(" ")
  end


  factory :loan_detail do |l|
    l.project FactoryGirl.create(:project)
    l.loan_type  FactoryGirl.create(:loan_type)
    l.grace_period  5
    l.interest_rate  5
    l.maturity 25
  end

  factory :scope do |s|

    # This scope requires donor=china
    # and year in (2009, 2010)

    scope_name = "Cancelled Certain Years"
    s.name scope_name
    s.description Faker::Lorem.words(10).join(" ")
    s.symbol "cancelled_certain_years"

    scope_channels = [
      [
        {
          "field" => "status_name",
          "values" => ["Cancelled"]
        },
        {
          "field" => "year",
          "values" => [2009,2010]
        }
      ]
    ]

    s.channels scope_channels
  end

end

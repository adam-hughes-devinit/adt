drop table if exists mbdc_rails_dump;
create table mbdc_rails_dump as
select 'def make_codes'
union all
select 'Currency.create!(name: "'||name||'", iso3: "'||iso||'")' rails from mbdc_currency
union ALL
select 'DocumentType.create!(name: "'||name||'")' from mbdc_document_type
union ALL
select 'FlowType.create!(name: "'||name||'")' from mbdc_flow
union ALL 
select 'OdaLike.create!(name: "'||name||'")' from mbdc_oda_like
union ALL
select 'OrganizationType.create!(name: "'||name||'", iati_code: "'||id||'")' from mbdc_org_type
union ALL
select 'Origin.create!(name: "'||name||'")' from mbdc_org_origin_type
union ALL
select 'Role.create!(name: "'||name||'")' from mbdc_role
union ALL
select 'Sector.create!(name: "'||name||'")' from mbdc_sector
union ALL
select 'SourceType.create!(name: "'||name||'")' from mbdc_source_type
union ALL
select 'Status.create!(name: "'||name||'")' from mbdc_status
union ALL
select 'Tied.create!(name: "'||name||'", iati_code: '||id||')' from mbdc_tied
union ALL 
select 'Verified.create(name: "'||name||'")' from mbdc_verified
union all
select 'end'
-- Countries
union ALL
select 'def make_countries'
union ALL 
select 'Country.create!(name: "'||name||'", '|| coalesce('iso3: "'||iso3||'",', '')||' '|| coalesce('iso2: "'||iso2||'",', '')||' '|| coalesce('oecd_name: "'||oecd_name||'",', '')||' '|| coalesce('oecd_code: '||oecd_code||',', '')||' '|| coalesce('cow_code: '||cow_code||',', '')||' '|| coalesce('un_code: '||un_code||',', '')||' '|| coalesce('imf_code: '||imf_code||',', '')||' '|| coalesce('aiddata_code: '||aiddata_code , '')||')' from mbdc_recipient
where iso3 is not null or iso2 is not null or oecd_code is not null or un_code is not null or cow_code is not null
union ALL
select 'end'
-- Organizations
union ALL 
select 'def make_organizations'
union ALL
select 'Organization.create!(name:"AidData")'
union ALL
select distinct 'Organization.create!(name: "'|| name||'" '|| coalesce(', organization_type: OrganizationType.find_by_iati_code('||org_type_id||')', '')||')' from mbdc_participating_org
where name != ''
union ALL
select 'end'
union ALL

-- Projects
select 'def make_projects'
Union ALL
select 'Project.create!(' ||
'owner: Organization.find_by_name("AidData"), ' ||
'media_id:'||id||', '||
coalesce('title: "'||title||'", ', '') ||
coalesce('description: "'||strip_tags(description)||'".gsub(/&nbsp;/, " "), ', '') ||

coalesce('capacity: "'||capacity||'", ', '') ||
coalesce('year: '||year||', ', '') ||
-- various booleans
coalesce('is_commercial: '||
	(case when is_commercial='t' then 'true' else 'false' end)
	||', ', '') ||
coalesce('active: '||
	(case when active='t' then 'true' else 'false' end)
	||', ', '')||
coalesce('year_uncertain: '||
	(case when year_uncertain='t' then 'true' else 'false' end)
	||', ', '')||
coalesce('debt_uncertain: '||
	(case when debt_uncertain='t' then 'true' else 'false' end)
	||', ', '')||
coalesce('line_of_credit: '||
	(case when is_line_of_credit='t' then 'true' else 'false' end)
	||', ', '')||
-- status
coalesce('status: Status.find_by_name("'||status||'"), ', '') ||
-- flow_type
coalesce('flow_type: FlowType.find_by_name("'||flow_type||'"), ', '' ) ||
-- oda like
coalesce('oda_like: OdaLike.find_by_name("'||oda_like||'"), ', '' ) ||
-- sector
coalesce('sector: Sector.find_by_name("'||sector||'"), ', '' ) ||
coalesce('sector_comment: "'||sector_comment||'", ', '') ||
-- tied
coalesce('tied: Tied.find_by_name("'||tied||'"), ', '' ) ||
-- verified
coalesce('verified: Verified.find_by_name("'||verified||'"), ', '' ) ||
-- dates
coalesce('start_planned: "'||start_planned||'".to_date, ', '') ||
coalesce('start_actual: "'||start_actual||'".to_date, ', '') ||
coalesce('end_planned: "'||end_planned||'".to_date, ', '') ||
coalesce('end_actual: "'||end_actual||'".to_date, ', '') ||
	
'donor: Country.find_by_name("China")) do |p|
p.id = '||id||'
p.save
end' 
from mbdc_project
left join (select id, sector, status, flow flow_type, oda_like, tied, verified from mbdc_full_view) extras using(id)
where donor_id = 
(select id from mbdc_donor where name= 'China')
union all
select 'end'
union ALL

-- Geopolitical
select 'def make_geopoliticals'
union ALL
select 'Project.find_by_media_id('||project_id||').geopoliticals.create!('|| coalesce('subnational: "'||detail||'", ', '') || coalesce('percent: '||percent||', ' , '' ) ||coalesce('recipient: Country.find_by_name("'||mbdc_recipient.name||'") ', '') ||')'
from mbdc_geopolitical
left join mbdc_recipient on recipient_id = mbdc_recipient.id
where project_id in (select project_id from mbdc_full_view view where donor_name='China')
union all
select 'end'
union ALL

-- Participating Organizations
select 'def make_participating_organizations'
union ALL
select 'Project.find_by_media_id('||project_id||').participating_organizations.create!('||
coalesce('role: Role.find_by_name("'||r.name||'"), ', '' ) || 
coalesce('origin: Origin.find_by_name("'||o.name||'"), ', '' ) || 
coalesce('organization: Organization.find_by_name("'||po.name||'") ', '' ) || ')'
from mbdc_participating_org po
left join mbdc_role r on po.role_id=r.id
left join mbdc_org_origin_type o on  po.org_origin_id = o.id
where project_id in (select project_id from mbdc_full_view view where donor_name='China')
union all
select 'end'
union ALL

-- Transactions
select 'def make_transactions'
union ALL
select 'Project.find_by_media_id('||project_id||').transactions.create!('||
coalesce('currency: Currency.find_by_name("'||c.name||'"), ', '') ||
coalesce('value:'||amount||' ', '') || ')'
from mbdc_transaction
left join mbdc_currency c on c.id=currency_id
where project_id in (select project_id from mbdc_full_view view where donor_name='China')
union all
select 'end'
union ALL

-- Contacts
select 'def make_contacts'
union ALL
select 'Project.find_by_media_id('||project_id||').contacts.create!('||
coalesce('organization: Organization.find_by_name("'||org||'"), ', '') ||
(case when length(info)>0 then 'position: "'||info||'", ' else '' end) ||
coalesce('name: "'||name||'" ', '') || ')'
from mbdc_contact
where project_id in (select project_id from mbdc_full_view view where donor_name='China')
union all
select 'end'
union ALL

-- Sources
select 'def make_sources'
union ALL
select 'Project.find_by_media_id('||project_id||').sources.create!('||
coalesce('source_type: SourceType.find_by_name("'||st.name||'"), ', '') ||
coalesce('document_type: DocumentType.find_by_name("'||dt.name||'"), ', '') ||
coalesce('date: "'||date||'".to_date, ', '') ||
coalesce('url: "'||address||'" ','') || ')'
from mbdc_source
left join mbdc_source_type st on st.id=source_type_id
left join mbdc_document_type dt on dt.id=document_type_id
where project_id in (select project_id from mbdc_full_view view where donor_name='China')
union all
select 'end'
union ALL

-- Users
select 'def make_users'
union ALL
select 'User.create!(' ||
coalesce('email: "'||name||'@email.wm.edu", ', '' ) ||
coalesce('name: "'||name||'", ', '') ||
'owner: Organization.find_by_name("AidData"), ' ||
'password: "a1dd4t4", password_confirmation: "a1dd4t4") '
from mbdc_user where opus_id=24723
union all
select 'User.create!(email: "rmosolgo@aiddata.org", '||
'name: "rmosolgo", ' ||
'owner: Organization.find_by_name("AidData"), ' ||
'password: "a1dd4t4", password_confirmation: "a1dd4t4") '
union all
select 'User.find_by_email("amstrange@email.wm.edu").toggle!(:admin)'
union all
select 'User.find_by_email("bfodonnell@email.wm.edu").toggle!(:admin)'
union all
select 'User.find_by_email("rmosolgo@aiddata.org").toggle!(:admin)'
union all
select 'User.create!(email: "bcparks@aiddata.org", name: "bcparks, owner: Organization.find_by_name("AidData"), password: "a1dd4t4", password_confirmation: "a1dd4t4", admin: true)'
union all
select 'end';

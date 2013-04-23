# Web Service API


## Project Data Feed

__Endpoint:__ `GET /projects.json?`. 

### Pagination

- Default limit: __50__
- pass `page` to get to subsequent pages
- or set `max` in your request.


### Query

If you're familiar with [Apache Solr](http://lucene.apache.org/solr/) or the (Sunspot)[http://sunspot.github.io/] gem, you've got a head start.

#### Facets

Each may take one value or multiple values.

- recipient_iso2
  - ISO2 of a country
- active_string
  - Active
  - Inactive
- crs_sector_name
  - name of a 3-digit CRS sector
- year
  - 4-digit year
- oda_like_name
  - __Misnomer__ -- should be "Flow class"
  - Takes a Flow class name
- flow_type_name
  - takes a Flow Type name
- intent_name
  - takes an Intent name
- organization_name
  - takes a name of an involved Organization
- role_name
  - takes a Role name (and matches projects which have an org of that role)
- country_name
  - full name of Recipient Country
- currency_name
  - name or reported currency
- scope_names
  - One of our __Scopes__
- status_name
  - takes a Status name
- year_uncertain_string


#### Text Search

- pass `search=your text query`


#### Response

- Responds with JSON representation of the project.

### Aggregate Data Feed

#### What it does
A user may specify which dimensions to aggregate by and how to filter and he or she will receive a list of data records with those dimensions and the aggregated USD-2009, the aggregated USD current (ie, not adjusted for inflation) and the count of projects.
#### Query

##### Select attributes
The aggregate data feed has one mandatory parameter, `get`. `get` takes any of the following field names: 

- donor
- year
- sector_name
- flow_class
- recipient_name
- recipient_iso2
- recipient_iso3

_These field names are somewhat subject to change (according to our needs). I should update this again before the launch._

##### Filter by attribute values
Besides using `get`, a user may also filter by attribute value:

- recipient_iso2
- flow_class
- sector_name
- flow_type
- year
- verified

_These filter names are somewhat subject to change (according to our needs). I should update this again before the launch._

The filters may be a single value (eg., `&recipient_iso=KE`) or many values (eg., `&recipient_iso2=KE*TZ*ZW`) (joined with "*"). Also, the filters may be combined (eg., `&recipient_iso=KE&flow_clas=ODA-like`).
##### Handle projects with multiple recipients
Some projects have more than one recipient. Sometimes, amounts may be divided among those recipients -- but sometimes they cannot. Users may select how to handle this problem with the `multiple_recipients` argument. A user may pass one of five values:

- `merge` __(Default if no value is passed)__ If a project has multiple recipients, the recipients are 'merged' and the amount is attributed to "Africa, regional". There is no risk of double-counting, but accuracy is lost.
- `percent_then_merge` If a project has multiple recipients and the _percent_ variable sums to 100% for that project, the amount is divided among recipients according to the _percent_ variable. Otherwise it is attributed to "Africa, regional".
- `share` If a project has multiple recipients, the amount is divided among those recipients equally.
- `percent_then_share` If a project has multiple recipients and the _percent_ variable sums to 100% for that project, the amount is divided among recipients according to the _percent_ variable. Otherwise it divided among those recipients equally.
- `duplicate` If a project has multiple recipients, the full amount is attributed to each recipient. __This introduces double-counting: the same amount is multiplied by the number of recipients.__ It is offered here for advanced users.

##### Merge World Bank's World Development Indicators with your data
If your data is aggregated by recipient-year, you can also request data from World Bank's Indicator API. Be warned that this kind of request is not efficient and will add quite a bit of time to your query. To add WDI data to your request:

- include `year` and `recipient_iso3` in your `&get=` string.
- add `&wdi=` with any number of comma-separated indicator codes from http://data.worldbank.org (eg, `NY.GNP.ATLS.CD` or `DC.DAC.USAL.CD`)

#### Response
_The data below is for example only_
The response is an array of JSON objects including aggregated USD-2009, current USD and project count by each field name. For example,
    
	/aggregates/projects?get=donor
	
returns an array with one object: 
    
	[{"donor":"CHN","usd_2009":"360180650450.82","usd_current":"326709526680.62","count":"2489"}]

A more complicated request returns a more detailed dataset:

    /aggregates/projects?get=year,recipient_name
	
which yields:

    [
			{"year":"2003","recipient_name":"Algeria","usd_2009":"423075585.45","usd_current":"262604080.93","count":"3"},
			{"year":"2011","recipient_name":"Gabon","usd_2009":"109047754.69","usd_current":"131549189.42","count":"2"},
			{"year":"2005","recipient_name":"Djibouti","usd_2009":"1751749.33","usd_current":"1220358.01","count":"1"},
			{"year":"2005","recipient_name":"Niger","usd_2009":"14071208.39","usd_current":"9802722.09","count":"5"},
    	...
    ]


Here is an example of filtering:

    /aggregates/projects?get=recipient_iso2&recipient_iso2=KE
	
which yields:

    [{"recipient_iso2":"KE","usd_2009":"2093704869.17","usd_current":"1813886723.69","count":"99"}]
	

Beyond this, you can combine filters and groups, like this:

   /aggregates/projects?get=flow_class,recipient_name&recipient_iso2=KE&year=2005

which yields:

	[
		{"recipient_name":"Kenya","flow_class":"CA +Gov","usd_2009":"2963815.82","usd_current":"2064745.40","count":"2"},
		{"recipient_name":"Kenya","flow_class":"ODA-like","usd_2009":"36672592.42","usd_current":"25548000.00","count":"3"},
		{"recipient_name":"Kenya","flow_class":"OOF-like","usd_2009":"34450533.04","usd_current":"24000000.00","count":"2"},
		{"recipient_name":"Kenya","flow_class":"Vague (Com)","usd_2009":"4306316.63","usd_current":"3000000.00","count":"1"},
		{"recipient_name":"Kenya","flow_class":"Vague (ODF)","usd_2009":"179807007.33","usd_current":"125262740.38","count":"4"}
	]
	
	
### Deflator 
The deflator web service has been expanded to support JSON data response which includes:


- deflated_amount
- current_amount
- input_amount
- year
- original_currency
- exchange_rate
- country
- deflator


See http://data.itpir.wm.edu/deflate for more background on this service.
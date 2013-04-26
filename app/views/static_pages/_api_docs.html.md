## Project Data Feed

__Endpoint:__ `GET /projects.json?`. 

### Pagination

- Default limit: __50__
- pass `page` to get to subsequent pages
- or set `max` in your request.


### Query


#### Facets

Each may take one value or multiple values. A full list of allowed values is forthcoming -- in the meantime, you can check the list of values at the [project search page](http://china.aiddata.org/projects).

- __recipient_iso2__: ISO2 of a country
- __active_string__: "Active" or "Inactive" _Inactive records should not be used for analysis_
- __sector_name__: name of a CRS sector _Alias: crs_sector_name_
- __year__: 4-digit year
- __flow_class_name__: Takes a Flow class name _Alias: oda_like_name_
- __flow_type_name__: takes a Flow Type name
- __intent_name__: takes an Intent name
- __organization_name__: takes a name of an involved Organization
- __role_name__: takes a Role name (and matches projects which have an org of that role)
- __country_name__: full name of Recipient Country
- __currency_name__: name or reported currency
- __scope_names__: One of our __Scopes__
- __status_name__: takes a Status name



#### Text Search

- pass `search=your text query`


#### Response

<pre class='teaser'>
The response is a JSON representation of the projects. For example:
<code>
  [
    {
      "active":true,
      "debt_uncertain":false,
      "id":2027,
      "is_cofinanced":false,
      "is_commercial":false,
      "line_of_credit":false,
      "title":"China grants Ghana 300m dollars to boost rural electrification",
      "year":2010,
      "year_uncertain":false,
      "usd_2009":278902889.56,
      "donor_name":"China",
      "crs_sector_name":"Energy Generation and Supply",
      "flow_type_name":"Monetary Grant (excluding debt forgiveness)",
      "oda_like_name":"ODA-like",
      "status_name":"Implementation",
      "recipient_condensed":"Ghana",
      "geopoliticals":
        [
          {
          "percent":100,
          "recipient":
            {
              "cow_code":452,
              "iso2":"GH",
              "iso3":"GHA",
              "name":"Ghana",
              "oecd_code":241
            }
          }
        ],
      "transactions":
        [
          {
            deflated_at":"2012-11-20T10:35:25-05:00",
            "deflator":1.0756432121391,
            "exchange_rate":1.0,
            "usd_current":300000000.0,
            "usd_defl":278902889.56,
            "value":300000000.0,
            "currency":
              {
                "iso3":"USD",
                "name":"US Dollar"
              }
            }
        ],
      "contacts":
        [
          {
            "name":"Dr. Francis Bawana Dankurah",
            "position":""
          }
        ],
      "sources":
        [
          {
            "date":"2010-08-20",
            "url":"http://global.factiva.com/aa/?ref=BBCAP00020100821e68l000jj&pp=1&fcpil=en&napc=S&sa_from=",
            "source_type":
              {"name":"Factiva"},
            "document_type":
              {"name":"Recipient media or official"}
          },
          {
            "date":"2011-01-20",
            "url":"http://global.factiva.com/aa/?ref=BBCAP00020110120e71k001jn&pp=1&fcpil=en&napc=S&sa_from=",
            "source_type":
              {"name":"Factiva"},
            "document_type":
              {"name":"Recipient media or official"}
          }
        ],
      "participating_organizations":
        [
          {
            "origin":
              {"name":"Recipient"},
            "organization":
              {"name":"Energy Commission of Ghana"},
            role":
              {"name":"Implementing"}
          }
        ]
    },
    ...
  ]

</code>
</pre>

</p>

## Aggregate Data Feed

An aggregate data feed is available at `GET /aggregates/projects`.

### What it does

A user may specify which dimensions to aggregate by and how to filter and he or she will receive a list of data records with those dimensions and the aggregated USD-2009, the aggregated USD current (ie, not adjusted for inflation) and the count of projects.

### Query

##### Select attributes
The aggregate data feed has one mandatory parameter, `get`. `get` takes any of the following field names: 

- donor
- status
- intent
- year
- crs_sector_name
- flow_class
- recipient_name
- recipient_iso2
- recipient_iso3

For example, you could request 
  
    ?get=donor,year

and you would receive:

    [
        {"donor":"CHN","year":"2011","usd_2009":"34893163505.19","usd_current":"42093185582.31","count":"221"},
        {"donor":"CHN","year":"2010","usd_2009":"52246044755.12","usd_current":"56198103402.03","count":"264"},
        {"donor":"CHN","year":"2009","usd_2009":"40084730266.30","usd_current":"40084730266.30","count":"252"},
        {"donor":"CHN","year":"2008","usd_2009":"32547140114.71","usd_current":"32183744289.11","count":"197"},
        {"donor":"CHN","year":"2007","usd_2009":"38081059582.42","usd_current":"31911731329.68","count":"286"}
        ...
    ]

##### Filter by attribute values
Besides using `get`, a user may also filter by attribute value:

- recipient_iso2
- recipient_name
- recipient_
- flow_class
- crs_sector_name
- intent_name
- flow_type
- status
- year        

The filters may be a single value:
    
    &recipient_iso=KE

or many values, joined with `*`
    
    &recipient_iso2=KE*TZ*ZW

Also, the filters may be combined:
    
    `&recipient_iso=KE*TZ*ZWflow_class=ODA-like`

##### Handle projects with multiple recipients

Some projects have more than one recipient. Sometimes, amounts may be divided among those recipients -- but sometimes they cannot. Users may select how to handle this problem with the `multiple_recipients` argument. A user may pass one of five values:

- `merge` __(Default if no value is passed)__ If a project has multiple recipients, the recipients are 'merged' and the amount is attributed to "Africa, regional". There is no risk of double-counting, but accuracy is lost.
- `percent_then_merge` If a project has multiple recipients and the _percent_ variable sums to 100% for that project, the amount is divided among recipients according to the _percent_ variable. Otherwise it is attributed to "Africa, regional".
- `share` If a project has multiple recipients, the amount is divided among those recipients equally.
- `percent_then_share` If a project has multiple recipients and the _percent_ variable sums to 100% for that project, the amount is divided among recipients according to the _percent_ variable. Otherwise it divided among those recipients equally.
- `duplicate` If a project has multiple recipients, the full amount is attributed to each recipient. __This introduces double-counting: the same amount is multiplied by the number of recipients.__ It is offered here for advanced users.



#### Response

_The data below is for example only_

The response is an array of JSON objects including aggregated USD-2009, current USD and project count by each field name. For example,
    
	/aggregates/projects?get=donor
	
returns an array with one object: 
    
	[{"donor":"CHN","usd_2009":"296501502995.56","usd_current":"269933245392.20","count":"2322"}]

A more complicated request returns a more detailed dataset:

    /aggregates/projects?get=year,recipient_name
	
which yields:

    [
        {"donor":"CHN","recipient_name":"Africa, regional","usd_2009":"21710513962.88","usd_current":"23563630384.69","count":"37"},
        {"donor":"CHN","recipient_name":"Algeria","usd_2009":"305887799.05","usd_current":"253841103.40","count":"16"},
        {"donor":"CHN","recipient_name":"Angola","usd_2009":"20877198922.85","usd_current":"16490164155.69","count":"45"},
        {"donor":"CHN","recipient_name":"Benin","usd_2009":"57197870.42","usd_current":"48403045.48","count":"11"},
    	  ...
    ]


Here is an example of filtering:

    /aggregates/projects?get=recipient_iso2&recipient_iso2=KE
	
which yields:

    [{"recipient_iso2":"KE","usd_2009":"1644741163.61","usd_current":"1397473824.13","count":"91"}]

Beyond this, you can combine filters and groups, like this:

   /aggregates/projects?get=flow_class,recipient_name&recipient_iso2=KE&year=2005

which yields:

	[
    {"flow_class":"CA +Gov","recipient_name":"Kenya","usd_2009":"2963815.82","usd_current":"2064745.40","count":"2"},
    {"flow_class":"FDI -Gov","recipient_name":"Kenya","usd_2009":"4306316.63","usd_current":"3000000.00","count":"1"},
    {"flow_class":"ODA-like","recipient_name":"Kenya","usd_2009":"4586384.37","usd_current":"3195109.49","count":"2"},
    {"flow_class":"OOF-like","recipient_name":"Kenya","usd_2009":null,"usd_current":null,"count":"2"},
    {"flow_class":"Vague (Official Finance)","recipient_name":"Kenya","usd_2009":"246343748.42","usd_current":"171615630.89","count":"5"}
	]
	

# Data Feeds

## Project Data Feed
The project data feed was implemented to feed "top projects" to the map visualization. It is available at /projects.json and takes exactly the same parameters as the search page. It defaults to 50 projects per page and only shows the first page of results unless the request includes `page` greater than 1. The number of projects per page can also be set by passing `max`. 


The best way to learn the project API is to insert `.json` into the search page URL and see what you get. 


## Aggregate Data Feed
 
### What it does
A user may specify which dimensions to aggregate by and he or she will receive a list of data records with those dimensions and the aggregated USD-2009. At present, the only filter available is "recipient_iso2."
### Query

The aggregate data feed has one mandatory parameter, `get`. `get` takes any of the following field names: 

- donor
- year
- sector_name
- recipient_name
- recipient_iso2
- recipient_iso3

_These field names are somewhat subject to change (according to our needs). I should update this again before the launch._

Besides `get`, a user may also filter by data value:
- recipient_iso2
- flow_class
- sector_name
- flow_type

_These filter names are somewhat subject to change (according to our needs). I should update this again before the launch._

The filters may be a single value (eg., `&recipient_iso=KE`) or many values (eg., `&recipient_iso2=KE,TZ,ZW`). Also, the filters may be combined (eg., `&recipient_iso=KE&flow_clas=ODA-like`).

### Response

The response is an array of objects including aggregated USD-2009 by each field name. For example,     
    
	/aggregates/projects?get=donor
	
returns an array with one object: 
    
	[{"usd_2009":419168261554.65955,"donor":"CHN"}]

A more complicated request returns a more detailed dataset:

    /aggregates/projects?get=year,recipient_name
	
which yields:

    [
    	{"usd_2009":1697245819.4,"year":2000,"recipient_name":"Africa, regional"},
    	{"usd_2009":15683908.9,"year":2000,"recipient_name":"Benin"},
    	{"usd_2009":16401473.36,"year":2000,"recipient_name":"Congo, Dem. Rep."} 
    	...
    ]
	
Here is an example of filtering:

    aggregates/projects?get=recipient_iso2&recipient_iso2=KE
	
which yields:

    [{"usd_2009":2368182328.74,"recipient_iso2":"KE"}]
	

## Deflator 
The deflator web service has been expanded to support JSON data response which includes:
- deflated_amount
- current_amount
- input_amount
- year
- original_currency
- exchange_rate
- country
- deflator
See data.itpir.wm.edu/deflate for more background on this service.
## World Bank WDI Web Service
The GNI and DAC ODA/GNI data comes from the World Bank WDI data feed. See data.worldbank.org.

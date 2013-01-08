# China App User's Guide
## Introduction
### Terminology

URLs below will be given in reference to a root path, which is the "base" of the all the addresses in this application. The root path is currently `china.aiddata.org`.

### Scope

This document is for transitioning from an internal data collection and management system for the media-based data collection project to a new application with improved security and stability. 

## What's the Same: Projects, Users

The central data object is still the project and it has the same components. It is still created and edited via form input. Projects are accessed by search-and-filter or directly by ID. 

Authorized users may create and edit projects. Unauthorized users may view projects but not edit them. Users exist in a more formalized structure: they belong to organizations (in our case, AidData), and some are admins. When a user creates a project, it belongs to his or her organization. Users can only edit projects that belong to their organization. Admins have special privileges, notably: editing codes, adding and removing users from the organization and deleting comments. A user's actions create log entries, visible on the user's "profile." 

## What's New: Codes, Comments, Flags, Organizations
Codes, which are supporting data for categorizing and tagging data records are now directly accessible to end users (with admin authorization). For example, to add a new sector, navigate to `[root]/sectors`. 

Any page visitor may leave comments on project pages. Admins may delete these comments. 

Any signed-in visitor may flag a project-associated data point with a defined flag type. Admins may delete these flags.

As an experiment in data ownership and user domain, there is also an organization  element in the user model. For our purposes, it's important to know that we can specify users who belong to AidData, and only those users have authorization over our projects. Should other organizations take interest in our projects, we can make them their own organizations, users and admins. 

## Projects

Many user activities begin with projects. This section addresses how to create, find and manipulate projects.
### Find a Project

A user may find projects by two methods. If the user knows the projects ID number, the user may go directly to the project via Navbar > Projects > Find by ID. Alternatively, the user may type in the URL : `[root]/projects/[ID]`. 

#### Searching
Users may also find projects by search-and-filter, which can be accessed via Navbar > Projects > Search and Filter or the URL `[root]/projects`. A user may enter a search query in the text input, then click search to return all matching projects. The search function covers all text fields in a project record, including accessory data such as contact name and subnational location detail. To filter the project list, a user may click one of the filters to see the available options, then click one of those options to show only projects which contain that value. In some cases, such as "recipient country", a project may have more than one value, so it will match more than one filter (eg, a project to Burundi and Rwanda will appear under a filter for Burundi and a filter for Rwanda). 

#### Scopes
There are a few defined _scopes_ for projects. They are a group of filters to help users find meaningful groups of data. They are available on the search panel. 

If a user is moving within a defined scope, there is a flash notification at the top of the search window to tell him which scope he is in.
##### Default Scope
The default scope is "Official Finance". A user is brought there by default, and notified by a notice on the page.

### View a Project

The external project page displays the various variables associated with a project and provides a place for viewers to leave comments. Admin users may delete comments on this page. For users who are signed in and belong to the organization who owns the record ("AidData"), there is a link to edit the project.

### Edit a project

Projects may be edited by signed-in users who belong to the same organization who owns the project records (often AidData). The edit page may be accessed in two ways: search and direct access. 

For users who belong to AidData, direct access is available via Navbar > Projects > Edit by ID. All users may type in the edit url: `[root]/projects/[ID]/edit`. (Of course, only authorized users will actually be able to edit the project. Unauthorized users will be redirected.)

Alternatively, users can access the edit page from search results. For authorized users, an "edit" link will appear on the far-right of each search result.
 
The functionality of the edit page is largely identical to the old page, although the style of the form is very different. The new form does not support rich text in the project description -- only plain text. 
### Creating Projects

The create page is accessible via Navbar > Projects > Create a project. Note that title is a required field. Only users who belong to an organization (likely AidData) can create projects. 
### Projects Belong to Organizations

When a user creates a project, it is associated with the organization that owns that user. Users who belong to the same organization (eg, other AidData research assistants) may edit that project, but other users may not. (All users, even if they are anonymous, may view the project page.)
## Exporting Data

### Exporting project data
Data can be exported from the search results page. The link appears above the search results. Project records are exported as CSV and include fixed set of fields in a fixed order, as described in the China release documentation (the fields aren't listed here). The fields can only be changed by altering the source code -- sorry!

### Exporting aggregate data
Aggregate data is available from `aggregates/export`. The interface provides three selections:
#### Fields to retrieve
These fields will become additional columns in the dataset. When you add a column, the data will be divided according to that column. For example, if you add "Flow Class" to your data set, you will get all finance, divided by Flow Class. If you then add "Recipient Name", you will get all finance divided by Flow Class _and_ Recipient. 

#### Filters and scopes
You may filter by one of several dimensions of a project. Also, you may select one of the preset scopes. You may combine custom filter selections with the scopes, but note that your selections will override the scope selection.

#### Select how to handle multiple recipients
Select how to handle projects with multiple recipients. For more information on these options, see __"Handle projects with multiple recipients"__ in the API description below.

#### See a preview
The exporter gives an _API Query Preview_, for users who wish to use the JSON API and a _Data Preview_ for uses who wish to use a CSV download.

#### Download to CSV
CSV is available via the dynamic download link.

#### Getting a CSV from the API
Aggregate data may be exported from the aggregate data feed, described in detail below. To get a CSV, simply send the request to `aggregates/projects.csv` instead of `aggregates/projects`.

### Implementation details of the project export function
Export data is stored in the caches table and controlled by the Cache model and Project model's `cache!` function. It was too slow to generate CSVs on the fly, so now, whenever a project is saved, its cache is updated also. Whenever a cache is saved, it also updates Cache Zero, which holds the _whole_ CSV. (So, when a user requests all projects, making a big select, we just give the one where project_id=0. I wonder if we'll add more specialized caches, like -1 for all active projects, etc.)

__Note__: This should be updated to reflect scopes -- it is likely that the CDF scope will get the most downloads, not the other scopes. 

## Users
### Sign up, Sign in, Sign out

Anyone may create an account from the sign-up path, `[root]/signup`, also available on the navbar. At the moment, there are three differences for users with accounts: 

- Their comments are associated with their accounts
- They can see "Recent Activity" on the home page
- Their "profile" pages include a list of their recent actions

Users with accounts can sign in and sign out through links on the navbar.
### Users Belong to Organizations

By default, users don't have organizational owners. But, after a user creates an account, an admin from an organization (likely AidData) can add that user to his or her organization from the list of users, available from the navbar or at `[root]/users`. The admin can also remove that user from the organization. 
Users who belong to an organization (likely AidData) can:

- edit projects which belong to their organization
- create projects which will belong to their organization
- see user "profiles" of other users in their organization (including recent activity)

This might seem like a strange behavior, but if we ever have an institutional partner, we can easily graft them in by creating a new organization and giving one of their users admin priviledges.
## Codes and Deflators 

### Codes

Codes are the various categorizations applied to project records and related data. For example sector, recipient country and flow class are codes. Codes can now be viewed from Navbar > Codes > (code name). Users who belong to AidData can edit, add and remove values for each code type. All users can see the code values, and via their individual pages, see which projects have that particular value. 

It's not possible to create a new code type from the web interface, only change values for existing codes.

When you change the value of an existing code (eg, change the name of country `Congo, Dem. Rep.` to `DRC`, or change the code of flow class "Vague (Com)" to `105`), all projects will be updated with the new value, the search index is updated and the export cache is updated. 

### Deflators
As before, deflation is handled by an external service, visible at `data.itpir.wm.edu/deflate`. Deflator data is stored with the project, so that if you export a project record, you can see 
- when it was deflated
- what exchange rate was used
- what deflator was used

These values are made available to decrease the "mystery" in the deflation process and make users more aware of the process.

## Comments
On each project page, there is a section to display comments and a form where any page visitor may leave a comment. Admin users see a "Delete comment" link. 

When someone leaves a comment, an email is sent to an Admin.

Hopefully, comments will provide a feedback loop for data users to report errors or recommend changes. AidData staff will respond to their comments as necessary. 

## Flags
### Purpose
Flags exist as a way for a user to bring attention to a specific data point. We encourage users to flag things for revision or to confirm existing data. 

__Forthcoming__: When a user creates a flag, an email is sent to an Admin.

### How To
Any user may flag a data point for review or confirmation. Flags are associated with project details. These flags are stored in the "Flags" tab and visible to all users. AidData admins may delete these flags.

## Data Feeds

Underneath the project platform there are several data feeds which could be useful for people making data visualizations. 

### Project Data Feed
The project data is available at /projects.json and takes exactly the same parameters as the search page. It defaults to 50 projects per page and only shows the first page of results unless the request includes `page` greater than 1. The number of projects per page can also be set by passing `max`. 


The best way to learn the project API is to insert `.json` into the search page URL and see what you get. 


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

The filters may be a single value (eg., `&recipient_iso=KE`) or many values (eg., `&recipient_iso2=KE,TZ,ZW`). Also, the filters may be combined (eg., `&recipient_iso=KE&flow_clas=ODA-like`).
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

_Sorry, the results aren't ordered, and at present, there is no way to order them!_

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
### World Bank WDI Web Service
The GNI and DAC ODA/GNI data comes from the World Bank WDI data feed. See http://data.worldbank.org.

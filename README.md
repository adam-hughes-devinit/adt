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

Users may also find projects by search-and-filter, which can be accessed via Navbar > Projects > Search and Filter or the URL `[root]/projects`. A user may enter a search query in the text input, then click search to return all matching projects. The search function covers all text fields in a project record, including accessory data such as contact name and subnational location detail. To filter the project list, a user may click one of the filters to see the available options, then click one of those options to show only projects which contain that value. In some cases, such as "recipient country", a project may have more than one value, so it will match more than one filter (eg, a project to Burundi and Rwanda will appear under a filter for Burundi and a filter for Rwanda). 

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

Data can be exported from the search results page. The link appears above the search results. Project records are exported as CSV and include fixed set of fields in a fixed order, as described in the China release documentation (the fields aren't listed here). The fields can only be changed by altering the source code -- sorry!

### Implementation details of export function
Export data is stored in the caches table and controlled by the Cache model and Project model's `cache!` function. It was too slow to generate CSVs on the fly, so now, whenever a project is saved, its cache is updated also. Whenever a cache is saved, it also updates Cache Zero, which holds the _whole_ CSV. (So, when a user requests all projects, making a big select, we just give the one where project_id=0. I wonder if we'll add more specialized caches, like -1 for all active projects, etc.)
 
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
As before, deflation is handled by an external service, visible at `data.itpir.wm.edu/deflate`. There are plans to embed deflation metadata with the project table so that end users can see the values used and when they were employed.

## Comments
On each project page, there is a section to display comments and a form where any page visitor may leave a comment. Admin users see a "Delete comment" link. 

Hopefully, comments will provide a feedback loop for data users to report errors or recommend changes. AidData staff will respond to their comments as necessary. This feature is somewhat experimental.

## Flags
### Purpose
Flags exist as a way for a user to bring attention to a specific data point. We encourage users to flag things for revision or to confirm existing data. 
### How To
Any user may flag a data point for review or confirmation. Flags are associated with project details. These flags are stored in the "Flags" tab and visible to all users. AidData admins may delete these flags.

## Data Feeds

Underneath the project platform there are several data feeds which could be useful for people making data visualizations. The EDs should decide if/why/how to make these public.

### Project Data Feed
The project data feed was implemented to feed "top projects" to the map visualization. It is available at /projects.json and takes exactly the same parameters as the search page. It defaults to 50 projects per page and only shows the first page of results unless the request includes `page` greater than 1. The number of projects per page can also be set by passing `max`. 


The best way to learn the project API is to insert `.json` into the search page URL and see what you get. 


### Aggregate Data Feed
The aggregate data feed was implemented for the map visualization. At first, it loaded by aggregating projects one-by-one, but it was far too slow.  The aggregate data feed allows the visualization to grab only the data it needs in a succinct format. Other tech-savvy users could get aggregate data this way and in the future, it could drive an aggregate exporter. 
#### What it does
A user may specify which dimensions to aggregate by and he or she will receive a list of data records with those dimensions and the aggregated USD-2009. At present, the only filter available is "recipient_iso2."
#### Query

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

#### Response

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
	
#### Looking forward
If the aggregate feed becomes a priority, it could be expanded to aggregate on more fields or filter on more fields. This document may become out of date if the implementation changes.

### Conduit
Conduit is a flexible, schema-less web service which was created to hold supporting (non-Chinese Development Finance) data for the map visualization. For more information about this service, visit its current homepage: aiddataconduit.herokuapp.com
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
See data.itpir.wm.edu/deflate for more background on this service.
### World Bank WDI Web Service
The GNI and DAC ODA/GNI data comes from the World Bank WDI data feed. See data.worldbank.org.

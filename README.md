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
Data can be exported from the search results page. The link appears above the search results. Users will be prompted to enter their email address and when the export is finished,
a link will appear to download the CSV file and an email will be sent to the user containing the CSV file as well.
The Project records are exported as CSV and include fixed set of fields in a fixed order, as described in the China release documentation (the fields aren't listed here). The fields can only be changed by altering the source code -- sorry!

### Exporting aggregate data
Aggregate data is available from `aggregates/export`. The interface provides three selections:
#### Fields to retrieve
These fields will become additional columns in the dataset. When you add a column, the data will be divided according to that column. For example, if you add "Flow Class" to your data set, you will get all finance, divided by Flow Class. If you then add "Recipient Name", you will get all finance divided by Flow Class _and_ Recipient. 

#### Filters and scopes
You may filter by one of several dimensions of a project. Also, you may select one of the preset scopes. You may combine custom filter selections with the scopes, but note that your selections will override the scope selection.

#### Select how to handle multiple recipients
Select how to handle projects with multiple recipients. For more information on these options, see __"Handle projects with multiple recipients"__ in the API description below.



### Implementation details of the project export function
Export data is stored in the caches table and controlled by the Cache model and Project model's `cache!` function. It was too slow to generate CSVs on the fly, so now, whenever a project is saved, its cache is updated also. Whenever a cache is saved, it also updates Cache Zero, which holds the _whole_ CSV. (So, when a user requests all projects, making a big select, we just give the one where project_id=0. I wonder if we'll add more specialized caches, like -1 for all active projects, etc.)

__Note__: This should be updated to reflect scopes -- it is likely that the CDF scope will get the most downloads, not the other scopes. 

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



# Deploying this rails app
- all your normal stuff: bundle update, `rake db:migrate`
- To create the development postgres database
  - Install PostgreSQL 8.4 or higher
  - Open the PostgreSQL shell by typing "psql"
  - `create role adt_user with login password 'aiddata'; create database adt_development with owner adt_user;`
  - Update pg_hba.conf to allow the user to sign in
    - Somewhere on your computer is a file called pg_hba.conf
    - Somewhere in that file it says "ident" under "METHOD"
    - Change "ident" to "md5"
    - Restart the postgresql service with something like "sudo service postgresql restart"
    - You'll know it works when you can log in to psql like this `psql -U adt_user adt_development --password`
    - `rake db:migrate`
    - log into psql with the command above then run `\i adt_production_2_6_2013.sql` to copy the data\
    - Restart the rails server 
    - `rake sunspot:solr:start` for the search engine. You will need to do this each time you log in to your computer
    - `rake sunspot:reindex`
    - `rake projects:recache` ??

- There are a few rake tasks that get the data up to speed:
  - `rake projects` runs various tasks on the project-related data
  

- Create an file called app_config.yml in the config directory containing two lines:

  `smtp_username: YOUR-GMAIL-USERNAME`
  
  `smtp_password: YOUR-GMAIL-PASSWORD`

  Don't worry, because app_config.yml is listed in the .gitignore file, your password won't get uploaded to Github

- Set up delayed_jobs to run task in the background
  - `rails generate delayed_job:active_record`
  - `rake db:migrate`
  - Then run `rake jobs:work` in a separate terminal or as a background process


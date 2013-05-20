
# Visualizations

Allow user-contributed visualizations a la http://bl.ocks.org

## How Blocks does it

draws from github __gists__, by gist ID. Gist _title_ is vis title, gist must have:

- _index.html_ which is used to render the vis


Gist may have:

- _thumbnail.jpg_ which is the thumbnail
- _readme.md_, rendered under the vis
- __Other files__, which can be pulled into the vis

## How we should do it

### User creates a gist

_Title_ serves as vis title. Gist must have:

- _index.html_

May have:

- Thumbnail
- Readme
- Other files


### User registers the gist with china.aiddta.org

- User must be signed in.
- We check that it meets the requirements
- We save: _gist_id_, _owner_id_

### We serve the vis

- If thumbnail, then we render it at `/visualizations/`
- We render it, along with supporting files, at `/visualizations/:id/`
  - index.html
  - other files may also be found
  - how do we offer the __readme__ ?

### Blocks caches and it's a pain to refresh

How should we do it?
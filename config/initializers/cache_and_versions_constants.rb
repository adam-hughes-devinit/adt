
# These are going to be used to determine whether caching is on or off. 
# It's on by default since it's necessary for the export,
# but it's so heavy that I turn it off for data imports.

CACHE_ONE ||= true # cache a project after save
CACHE_ALL ||= true # cache all after saving 1 cache
VERSION_CONTROL ||=true # paper trail is active




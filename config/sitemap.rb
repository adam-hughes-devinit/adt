# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://china.aiddata.org"

SitemapGenerator::Sitemap.create do
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Add static pages

  # The root path '/' and sitemap index file are added automatically for you.
    add bubbles_path
    add map_path

  # add content pages
    Content.find_each do |content|
      if ["Page", "Complex Page"].include? content.content_type
        add content_by_name_path(content.name), :changefreq => 'weekly'
      end
    end

  # Add '/projects' and all projects:
    add projects_path, :priority => 0.7, :changefreq => 'daily'
    Project.find_each do |project|
       add project_path(project), :lastmod => project.updated_at, :changefreq => 'daily'
    end

  # Add resources
    add resources_path, priority: 0.7, changefreq: 'daily'
    Resource.find_each do |resource|
      add resource_path(resource), lastmod: resource.updated_at, changefreq: "weekly"
    end
    
end

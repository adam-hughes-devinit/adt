class Content < ActiveRecord::Base
  attr_accessible :content, :name, :chinese_name, :content_type, :chinese_content

  has_paper_trail

  CONTENT_TYPES = [
      "Page", # Markdown content
      "Complex Page", # Ruby content, must return HTML
      "Internal", # Markdown content
      # Used in building other views:
      "Faculty/Staff",
      "Research Assistant",
      "AidData Publication",
      "Affiliate Publication",
      "Other Publication",
      "News Article",
      "Blog Post"
    ]

  validates_inclusion_of :content_type, in: CONTENT_TYPES

  def meet_the_team
    fac_staff = ""

    Content.find_all_by_content_type("Faculty/Staff")
    .sort{|a,b|
      (a.data["position"] && b.data["position"]) ? a.data["position"] <=> b.data["position"] : ( a.data["position"] ? -1 : 1 ) }
    .each_slice(2) { |slice|

      fac_staff += "<div class='row-fluid' style='margin:10px;'>"

      fac_staff += slice.map { |f|
        html = "
      <div class='span2' >

     #{image_tag "people/#{f.name.downcase.gsub(/\s/, "_")}.png", class: 'team-image'}

      </div>
      <div class='span4'>
        <h4>
          #{f.name}
          <small>
            <a href='mailto:china@aiddata.org?subject=Message for #{f.name}'>
              E-mail
            </a>
          </small>
        </h4>
        <p class='teaser'>
          #{f.data["description_html"]}
        </p>
      </div>
    "
        }.join
        fac_staff += "</div>"

      }

      ras = ""

      Content.find_all_by_content_type("Research Assistant").each_slice(3).each do |slice|

        ras += "<div class='row-fluid'>"

        slice.each do |f|
          details = []

          if (year = f.data["class"]) && (year.to_s =~ /[0-9]/)
            details.push "Class of #{f.data["class"]}"
          end

          if major = f.data["major"]
            details.push "Major: #{f.data["major"]}"
          end
          ras += "
     <div class='span1'>

        #{image_tag "people/#{f.name.downcase.gsub(/\s/, "_")}.png", class: 'team-image'}

      </div>
      <div class='span3'>
        <h4>
          #{f.name}
        <br>
          <small>
            #{
          details.join(" | ")
          }
          </small>
        </h4>
      </div>

  "
      end

      ras += "</div>"

    end


    content = "

  ## Faculty/Staff

  #{fac_staff}

  ## Research Assistants

  #{ras.html_safe}


    "
    #Markdown.new(content).to_html

  end

  def data

    begin
      data = YAML.load(content)
    rescue
      # in case YAML is malformed
      data = {}
    end

    data
  end

  def to_english
    "#{name.titleize} #{chinese_name.present? ? "(#{chinese_name})" : ""}"
  end

  def page_content
    if content_type == "Complex Page" 
      if persisted?
        pc = Markdown.new(content).to_html
        pc << Markdown.new(chinese_content).to_html if chinese_content
        #require 'open-uri'
        #app_root = Rails.env.production? ? "http://china.aiddata.org" : "http://localhost:3000" 
        #pc = open("#{app_root}/content/#{CGI::escape(name)}"){|io| io.read}
      else
        pc = content
      end
    elsif  content_type == "Page"
      pc = Markdown.new(content).to_html
      pc << Markdown.new(chinese_content).to_html if chinese_content
    else
      pc = content
    end
    pc
  end

  searchable if: proc { |c| ["Page", "Complex Page"].include?(c.content_type)} do 
    text :id, :name, :chinese_name, :page_content, :content_type
  end

end

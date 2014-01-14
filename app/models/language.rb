class Language < ActiveRecord::Base
  attr_accessible :name, :code

  has_many :resources

  before_save :update_resource_lang

  def save_lang(resource, resource_language)
    a = ['en','fr','zh']
    if a.include?(resource_language)

      language = Language.find_by_code(resource_language)
      resource.language_id = language.id
      if resource.save
        puts "I saved?"
      end

    else
      resource.language_id = 0
      resource.save
    end
  end

   # Find resources with no language and determines language.
  def update_resource_lang
    require 'nokogiri'
    require 'open-uri'
    require 'uri'

    DetectLanguage.configure do |config|
      config.api_key = "927256800b03882160b17f08badd5e7f"
    end

    count = 0
     # Get first 500 resources with no language.
    resources = Resource.where("language_id IS NULL").first(500)
    resources.each do | resource |
      count = count+1
      puts ("count: %s" % count)
      puts resource.id

       # Determine, which url to use.
      if !resource.download_url.blank?
        url = resource.download_url
      else
        url = resource.source_url
      end

      if (!url.nil?) and (url =~ URI::regexp)

        begin
          file = open(url)

           # Handle PDFs
          if url =~ (/\A(http:\/\/+).+(\.pdf)\z/)
            begin
              reader = PDF::Reader.new(file)
              page = reader.page(1) # only translate first page.
              text = page.text
              puts text
              begin
                 # Determines language.
                resource_language = DetectLanguage.simple_detect(text)
                puts resource_language
                save_lang(resource, resource_language)
              rescue EOFError
                puts "encountered EOFError"
                resource.language_id = 0
                resource.save
              end
            rescue PDF::Reader::MalformedPDFError
              puts 'MalformedPDFError'
              resource.language_id = 0
              resource.save
            end

           # Handle html files
          else
            whole_doc = Nokogiri::HTML(file)

            if !whole_doc.nil?

               # Get html body and remove javascript.
              whole_doc.css('script').remove
              whole_doc.css('style').remove
              whole_doc.xpath('//body').each do | doc |
                doc = doc.inner_html.encode('utf-8')
                doc_string = doc.to_s
                begin
                   # Strip out html code
                  clean_page = ActionView::Base.full_sanitizer.sanitize(doc_string)
                  clean_page = clean_page.split.join(" ")
                  clean_page = clean_page.delete! '&#160;'
                  puts clean_page

                   # Determines language.
                  resource_language = DetectLanguage.simple_detect(clean_page)
                  puts resource_language
                  save_lang(resource, resource_language)
                rescue ArgumentError
                  puts 'Could not sanitize. Probably due to: invalid byte sequence in UTF-8'
                  resource.language_id = 0
                  resource.save
                end
              end
            end
          end

          # Handle a bunch of errors.
        rescue SocketError, Errno::ETIMEDOUT, Zlib::BufError, Net::HTTPBadResponse, OpenURI::HTTPError, RuntimeError, Errno::ENOENT, Errno::EHOSTUNREACH, EOFError, Zlib::DataError, Errno::ECONNRESET, Errno::ECONNREFUSED, URI::InvalidURIError
          puts "Socket/Http/TimedOut/Buf Error :("
          resource.language_id = 0
          resource.save
        end
      end
    end
  end
end

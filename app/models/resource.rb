class Resource < ActiveRecord::Base

  include AmazonHelper
  include ResourceSearchable

  has_paper_trail 
  has_many :flags, as: :flaggable, dependent: :destroy
  accepts_nested_attributes_for :flags
  belongs_to :language

  RESOURCE_TYPES = [
    "Government Source (Donor/Recipient)",
    "Implementing/Intermediary Agency Source",
    "Other Official Source (non-Donor, non-Recipient)",
    "NGO/Civil Society/Advocacy",
    "Academic Journal Article",
    "Other Academic (Working Paper, Dissertation)",
    "Media Report, including Wikileaks",
    "Social Media, including Unofficial Blogs",
    "Other"
  ]

  attr_accessible :authors, :dont_fetch, :download_url,
  :fetched_at, :publish_date, :publisher,
  :publisher_location, :resource_type, :title, :source_url,
  :project_ids, :projects_count, :language_id, :language

  validates_uniqueness_of :source_url
  validates_presence_of :source_url, :title
  validates_inclusion_of :resource_type, in: RESOURCE_TYPES
  validates_format_of :source_url, :with => URI::regexp

  after_save :fetch!, if: Proc.new {|r| r.source_url_changed? }
  after_save :set_projects_count

  has_and_belongs_to_many :projects, uniq: true
  # I Wish. delegate :title, :description, to: :projects, prefix: true


  def self.resource_types
    RESOURCE_TYPES
  end

  def set_projects_count
    # homebrewed counter_cache since not supported for habtm
    self.update_column :projects_count, self.projects.count
  end

  def to_citation
    # Author's last name, first name. Book title. Additional information. City of publication: Publishing company, publication date.
    # Author's last name, first name. "Title of Article." Title of Encyclopedia. Date. 
    # Author's last name, first name. "Article title." Periodical title Volume # Date: inclusive pages. 

    citation = "#{authors.present? ? "#{authors}." : ""} \"#{title}.\"" +
      " #{publisher.present? ? "<i>#{publisher}</i>." : ""}" +
      " #{publish_date.present? ? "#{publish_date}." : ""}" +
      " Accessed: #{dont_fetch ? created_at : fetched_at}. " +
      " <a href='#{source_url}'>#{source_url}</a>."

    citation.html_safe
  end

  def to_english
    "#{title} #{publisher.present? ? ", #{publisher}" : ""} (#{resource_type})"
  end

  def to_iati
    %{
      <document-link url="#{CGI::escape source_url}" data-url-was-escaped="true">
        <title>#{title}</title>
        <category vocabulary="AidData-China">#{resource_type}</category>
      </document-link>
    }
  end


  def devour!(other_resource)
    other_resource.projects.each do |project|
      projects << project
    end

    success = self.save!
    other_resource.destroy if success
    return success

  end


  def fetch!
    update_column :fetched_at, nil
    update_column :download_url, nil
    new_fetched_at = Time.new
      if !(dont_fetch) && source_url[0..3]=='http'
        require 'open-uri'

        begin
          bucket_name = Rails.env.production? ? 'china_resources' : 'china_resources_dev'
          resource_copy = open(source_url)
          # pull the last bit from the URL
          s3_filename = source_url.gsub(/^.*\/(.*)$/, '\1')

          # if pulling name from URL doesn't work:
          s3_filename = "#{title}".gsub(/\//, '-') if s3_filename.blank?

          timestamp = Time.new.to_s.gsub(/[\s:]+/, '_')
          s3_filename =  "#{timestamp}_#{s3_filename}" #.gsub(/[\s:]/, '_')

          # store it in bucket/id/filename
          # p "RESOURCE: Saving #{s3_filename} from #{source_url} to #{bucket_name}/#{id}"
        filename = s3_upload bucket_name, resource_copy, "#{id}/#{s3_filename}"

        new_download_url = "http://s3.amazonaws.com/#{bucket_name}/#{id}/#{CGI::escape s3_filename}"
        success = true
      rescue Exception => e
        p e.message
        new_download_url = nil
        success = false
      end
    end

    self.update_column :fetched_at, new_fetched_at
    self.update_column :download_url, new_download_url
    return success
  end
  handle_asynchronously :fetch!

end

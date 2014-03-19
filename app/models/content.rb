class Content < ActiveRecord::Base
  attr_accessible :content, :name, :chinese_name, :chinese_content, :searchable

  has_paper_trail

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
    pc = Markdown.new(content).to_html
    pc << Markdown.new(chinese_content).to_html if chinese_content
    pc
  end

  searchable if: :searchable? do
    text :id, :name, :chinese_name, :page_content
  end

end

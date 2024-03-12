module ApplicationHelper
  require 'uri'

  def pages_url(pageid)
    "#{ENV['PAGE_URL']}/#{pageid}.html"
  end

  def pages_versioned_url(version, pageid)
    "#{ENV['PAGE_URL']}/#{version}/#{pageid}.html"
  end

  def mediawiki_url(title, version)
    space_repalced = title.gsub(' ', '_')
    "#{mediawiki_url_prefix(version)}#{URI.encode_www_form_component space_repalced}"
  end
end

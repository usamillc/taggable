module EntityLinksHelper
  require 'uri'

  def mediawiki_url_prefix(version)
    case version
    when ENV['CURRENT_VERSION'] then
      ENV['CURRENT_PAGE_URL_PREFIX']
    else
      ENV['DEFAULT_PAGE_URL_PREFIX']
    end
  end

  def parse_title(url, version)
    prefix = mediawiki_url_prefix(version)
    if url.start_with?(prefix)
      url = URI.decode_www_form_component(url)
      return url[prefix.length..-1].gsub('_', ' ')
    end
  end
end

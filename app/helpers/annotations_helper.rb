module AnnotationsHelper
  def html_escape(s)
    s.gsub('&', '&amp;')
      .gsub('<', '&lt;')
      .gsub('>', '&gt;')
  end
end

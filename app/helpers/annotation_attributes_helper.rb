module AnnotationAttributesHelper
  def translate(ja)
    AnnotationAttribute.find_by(screenname: ja)&.name
  end
end

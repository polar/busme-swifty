
#
# This class is only a partial of the real in buspass-web
# because it carries CarrierWave and we don't need that here.
#
class FrontendKey
  include MongoMapper::Document

  belongs_to :frontend

end
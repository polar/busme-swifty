class Backend
  include MongoMapper::Document

  key :master_slug
  key :host
  key :port

  attr_accessible :master_slug, :host, :port

end
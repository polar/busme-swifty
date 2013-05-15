class Backend
  include MongoMapper::Document

  key :master_slug
  key :host
  key :port
  key :frontend # Fully Qualified Domain Name (front)    busme.us, sites.busme.us, etc. Used in Keepalive

  attr_accessible :master_slug, :host, :port, :frontend

end

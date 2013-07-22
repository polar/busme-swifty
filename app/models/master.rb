class Master
  include MongoMapper::Document

  # We have just enough here to get the id.
  key :slug
end
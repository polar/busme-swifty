class Frontend
  include MongoMapper::Document

  key :host
  key :hostip
  key :host_type

  key :name

  many :backends, :dependent => :destroy

  before_validation :ensure_name

  def ensure_name
    self.name = "#{host}" if name.nil?
  end

  validates_uniqueness_of :host, :allow_nil => false
end
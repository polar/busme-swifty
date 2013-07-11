class Backend
  include MongoMapper::Document

  key :frontend_address, String, :default => "0.0.0.0"
  key :master_slug
  key :frontend_local, Boolean, :default => true
  key :hostname
  key :server_name
  key :cluster_address, String, :default => "127.0.0.1"
  key :cluster_port
  key :address, String, :default => "0.0.0.0"
  key :port
  key :timeout

  key :configured, Boolean, :default => false

  key :name

  belongs_to :frontend

  before_validation :ensure_hostname, :ensure_name

  attr_accessible :frontend, :frontend_id
  attr_accessible :frontend_address, :master_slug, :hostname
  attr_accessible :server_name, :cluster_address, :cluster_port, :address, :port

  def frontend_name
    frontend.name
  end

  def ensure_hostname
    if ! master_slug.blank?
      self.hostname = "#{master_slug}.#{frontend.host}"
    else
      self.hostname    = "#{frontend.host}"
      self.server_name = "*.#{frontend.host}"
    end
  end

  def host
    if frontend_local && address == "0.0.0.0"
      frontend.host
    else
      address
    end
  end

  def ensure_name
    if name.nil?
      if master_slug.blank?
        self.name = "Z-#{frontend.name}-#{hostname}-#{frontend_address}-#{cluster_address}-#{cluster_port}-#{address}-#{port}"
      else
        self.name = "A-#{frontend.name}-#{hostname}-#{frontend_address}-#{cluster_address}-#{cluster_port}-#{address}-#{port}"
      end
    end
    return name
  end

  def spec
    "#{name}"
  end

  validates_uniqueness_of :name
  validates_presence_of :frontend_address
  validates_presence_of :cluster_address
  validates_numericality_of :cluster_port
  validates_uniqueness_of :cluster_port, :scope => :cluster_address
  validates_presence_of :address
  validates_numericality_of :port
  validates_uniqueness_of :port, :scope => :address


end

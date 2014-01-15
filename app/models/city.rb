class City < ActiveRecord::Base
  default_scope :order => "name"    # Retrieve cities sorted by name
  has_one :dataset
  has_one :mod_config
  has_many :dataserver_url
end

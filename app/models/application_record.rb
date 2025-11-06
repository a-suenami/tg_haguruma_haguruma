# typed: false

class ApplicationRecord < ActiveRecord::Base
  extend Enumerize

  primary_abstract_class
end

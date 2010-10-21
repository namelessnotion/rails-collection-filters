require 'active_support/dependencies'

module CollectionFilters
  autoload :Filter, 'collection_filters/filter'
  
  module Controllers
    autoload :Helpers, 'collection_filters/controllers/helpers.rb'
  end
  
  CONTROLLERS = ActiveSupport::OrderedHash.new
end

ActionController::Base.send :include, CollectionFilters::Controllers::Helpers
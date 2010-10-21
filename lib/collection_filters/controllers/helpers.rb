module CollectionFilters
  module Controllers
    module Helpers
      extend ActiveSupport::Concern
      
      included do
        helper_method :has_filter
      end
    
      def filtered_collection(target)
        self.class.collection_filter.apply(self.params[:filter], target)
      end
    
      module ClassMethods
        def filter_collections
          self.collection_filter =  Filter.new(self.controller_name.to_sym)
          CollectionFilters::CONTROLLERS[self.controller_name.to_sym] = self
        end

        def has_filter(scope_name, options = {})
          filter_collections unless filtered_collection?
          self.collection_filter.add(scope_name, options)
        end
      
        def collection_filter
          class_variable_get(:@@collection_filter)
        end
      
        def collection_filter= (cfilter)
          class_variable_set(:@@collection_filter, cfilter)
        end
      
        protected
        def filtered_collection?
          class_variable_defined?(:@@collection_filter)
        end
      
      end
    end
  end
end
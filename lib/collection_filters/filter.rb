module CollectionFilters
  class Filter
    def initialize(collection_name)
      @filters = {}
    end
    
    def add(filter, options = {})
      if options[:sort]
        sort_options = options[:sort]
        
        #add the sort aliases as well
        add(sort_options[:asc], :boolean => true)
        add(sort_options[:desc], :boolean => true)
        
        proc_filter = Proc.new { |target, direction|
          direction = direction.to_sym unless direction.is_a?(Symbol)
          if [:asc, sort_options[:asc]].include?(direction)
            target.send(sort_options[:asc])
          elsif [:desc, sort_options[:desc]].include?(direction)
            target.send(sort_options[:desc])
          end
        }
        add_filter(filter, :sort, proc_filter)
      elsif options[:boolean]
        scope = filter
        proc_filter = Proc.new { |target, value| 
          if value == false
            target
          else
            target.send(scope)
          end
        }
        add_filter(filter, :boolean, proc_filter)
      else
        scope = filter
        proc_filter = Proc.new { |target, value| target.send(scope, value) }
        add_filter(filter, :hash, proc_filter)
      end
    end
    
    def apply(params, target, options = {})
      target = target.scoped
      params.symbolize_keys.each do |filter_name, value|
        target = @filters[filter_name][:proc].call(target, value)
      end
      target
    end
    
    def [](filter_name)
      @filters[filter_name][:proc]
    end
    
    
    private
    def add_filter(name, type, proc)
      @filters[name] = {:type => type, :proc => proc}
    end
  end
end
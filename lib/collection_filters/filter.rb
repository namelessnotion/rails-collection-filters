module CollectionFilters
  class Filter
    def initialize(collection_name)
      @filters = {}
      @default_filters = {}
      @strict_filter = {}
    end
    
    def add(filter, options = {})
      add_filter_options = {}
      add_filter_options[:default] = options[:default] if !options[:default].nil?
      add_filter_options[:strict] = options[:strict] if !options[:strict].nil?
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
        add_filter(filter, :sort, proc_filter, add_filter_options)
      elsif options[:boolean]
        scope = filter
        proc_filter = Proc.new { |target, value| 
          if value == false
            target
          else
            target.send(scope)
          end
        }
        add_filter(filter, :boolean, proc_filter, add_filter_options)
      else
        scope = filter
        proc_filter = Proc.new { |target, value| target.send(scope, value) }
        add_filter(filter, :hash, proc_filter, add_filter_options)
      end
    end
    
    def apply(params, target, options = {})
      if !(params.nil? || params.empty?)
        target = target.scoped
        params.symbolize_keys.each do |filter_name, value|
          target = @filters[filter_name][:proc].call(target, value)
        end
        
        
      elsif !@default_filters.empty?
        target = target.scoped
        @default_filters.each do |filter_name, filter|
          target = filter[:proc].call(target, filter[:args])
        end
      end
      target
    end
    
    def [](filter_name)
      @filters[filter_name][:proc]
    end
    
    
    private
    def add_filter(name, type, proc, options = {})
      @filters[name] = {:type => type, :proc => proc}
      
      if options[:default]
        @default_filters[name] = { :type => type, :proc => proc, :args => options[:default]}
      end
      
      if options[:strict]
        @default_filters[name] = { :type => type, :proc => proc, :args => options[:strict]}
      end
    end
  end
end
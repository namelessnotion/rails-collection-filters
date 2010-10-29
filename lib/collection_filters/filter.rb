module CollectionFilters
  class Filter
    def initialize(collection_name)
      @filters = {}
      @default_filters = {}
      @strict_filters = {}
    end
    
    def add(filter, options = {})
      add_filter_options = { :children => [] }
      add_filter_options[:default] = options[:default] if !options[:default].nil?
      add_filter_options[:strict] = options[:strict] if !options[:strict].nil?
      if options[:sort]
        sort_options = options[:sort]
        
        #add the sort aliases as well
        add(sort_options[:asc], :boolean => true)
        add(sort_options[:desc], :boolean => true)
        add_filter_options[:children] << sort_options[:asc]
        add_filter_options[:children] << sort_options[:desc]
        
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
      applied_filters = []
      if !(params.nil? || params.empty?)
        params.symbolize_keys.each do |filter_name, value|
          if(@strict_filters[filter_name].nil? && !@filters[filter_name].nil?) #strict filters can not be applied via params
            target = scoped_target(target)

            target = @filters[filter_name][:proc].call(target, value)
            applied_filters << filter_name
          end
        end
      end
        
      if !@default_filters.empty?
        target = scoped_target(target)

        @default_filters.each do |filter_name, filter|
          #only apply a default filter if the filter has not been applied
          #and the filter's children have not been applied
          target = filter[:proc].call(target, filter[:args]) if ((filter[:children] << filter_name) & applied_filters).empty?
        end
      end
      
      if !@strict_filters.empty?
        target = scoped_target(target)
        @strict_filters.each do |filter_name, filter|
          target = filter[:proc].call(target, filter[:args])
        end
      end
      
      target
    end
    
    def [](filter_name)
      @filters[filter_name][:proc]
    end
    
    
    private
    
    def scoped_target(target)
      if target.respond_to?(:scoped)
        target = target.scoped
      end
      target
    end
    
    def add_filter(name, type, proc, options = {})
      @filters[name] = {:type => type, :proc => proc}
      
      if options[:default]
        @default_filters[name] = { :type => type, :proc => proc, :args => options[:default], :children => options[:children] }
      end
      
      if options[:strict]
        @strict_filters[name] = { :type => type, :proc => proc, :args => options[:strict]}
      end
    end
  end
end
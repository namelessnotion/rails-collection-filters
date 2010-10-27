require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')



describe CollectionFilters::Controllers::Helpers do
  
  def mock_filters(stubs = {})
    @mock_filters ||= mock("Mock Filters", stubs)
  end
  
  def mock_animals_male_collection(stubs = {})
    @mock_animals_male_collection ||= mock("Mock Animals Male Collection", stubs)
  end
  
  include RSpec::Rails::ControllerExampleGroup
  
  describe "Filtering a Collection in controllers" do
    before(:each) do
      CollectionFilters::Filter.stub!(:new).and_return(mock_filters)
    end
    describe "Loading filters" do
      it "should load a new CollectionFilter instance" do
        mock_filters.stub!(:add).with(:by_type, {})
        CollectionFilters::Filter.should_receive(:new).with(:widgets).and_return(mock_filters)
        class Widgets < ActionController::Base
          has_filter :by_type
        end
      end
      
      it "should add filters to CollectionFilter instance" do
        mock_filters
        @mock_filters.should_receive(:add).with(:by_type, {})
        
        CollectionFilters::Filter.stub!(:new).with(:cogs).and_return(@mock_filters)
        class Cogs < ActionController::Base
          has_filter :by_type
          def index; end
        end
        
      end
    end
    

    
    describe "Adding Filters to Controller" do
      describe AnimalsController do
        before(:each) do
          @mock_filters.stub!(:add)
        end
        
        it "should apply CollectionFilter filter to collections" do
          @mock_filters.should_receive(:apply).with({"by_gender" => "male"}, Animal).and_return(mock_animals_male_collection)
          AnimalsController.collection_filter= @mock_filters
          get :index, :filter => { "by_gender" => "male" }
        end
        
        it "should apply boolean sort filters to collections" do
          mock_animals_newest_first = mock("Animals Newest First")
          @mock_filters.should_receive(:apply).with({"newest_first" => true}, Animal).and_return(mock_animals_newest_first)
          AnimalsController.collection_filter= @mock_filters
          get :index, :filter => { "newest_first" => true }
        end
        
        it "should apply boolean sort filters to collections" do
          mock_animals_newest_first = mock("Animals Newest First")
          @mock_filters.should_receive(:apply).with({"by_created_at" => "desc"}, Animal).and_return(mock_animals_newest_first)
          AnimalsController.collection_filter= @mock_filters
          get :index, :filter => { "by_created_at" => "desc" }
        end
        
        it "should apply nil params" do
          mock_animals = mock("Animals")
          @mock_filters.should_receive(:apply).with(nil, Animal).and_return(mock_animals)
          AnimalsController.collection_filter= @mock_filters
          get :index
        end
      end
    end
  end
end

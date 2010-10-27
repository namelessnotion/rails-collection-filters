require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#this is mostly here as an example
class Animal < ActiveRecord::Base
  scope :by_gender, lambda { |gender| where(:gender => gender)}
  
  scope :newest_first, order("created_at DESC")
  scope :oldest_first, order("created_at ASC")
  scope :active, where(:active => true)
  scope :publish, where(:publish => true)
  
end

describe CollectionFilters::Filter do
  before(:each) do
    @filter = CollectionFilters::Filter.new(:animals)
    @filter.add(:by_gender)
    @filter.add(:by_status)
    @filter.add(:by_created_at, :sort => { :desc => :newest_first, :asc => :oldest_first})
    @filter.add(:active, :boolean => true)
  end
  describe "#add" do
    it "should add filters to hash" do
      @filter[:by_gender].should be_a_kind_of Proc
    end
    
    it "should create filter proc" do
      Animal.should_receive(:by_gender).with("male")
      @filter[:by_gender].call(Animal, "male")
    end
    
    describe "adding sorting filters" do
      
      it "should create a sorting filter proc alias" do
        Animal.should_receive(:newest_first).with(no_args)
        @filter[:by_created_at].call(Animal, "newest_first")
      end
      
      it "should create a sorting filter proc that handles DESC/ASC" do
        Animal.should_receive(:oldest_first).with(no_args)
        @filter[:by_created_at].call(Animal, "asc")
      end
      
    end
    
    describe "adding boolean filters" do
      it "should create a boolean filter" do
        Animal.should_receive(:active).with(no_args)
        @filter[:active].call(Animal, true)
      end
    end
  end
  
  describe "#apply" do
    
    before(:each) do
      @scoped_animal = mock("Anonymous Scoped Animal")
      Animal.stub!(:scoped).and_return(@scoped_animal)
    end
    
    it "should apply the filter to the target" do
      mock_female_animals = mock("Female Animals")
      @scoped_animal.should_receive(:by_gender).with("female").and_return(mock_female_animals)
      target = Animal
      params = {"by_gender" => "female"}
      @filter.apply(params, target).should == mock_female_animals
    end
    
    it "should apply all filters to the target" do
      mock_animals_for_sale = mock("Animals for Sale")
      mock_male_animals = mock("Male Animals")
      mock_male_animals_for_sale = mock("Male Animals For Sale")
      
      #the of applying scopes is not guaranteed 
      @scoped_animal.stub!(:by_status).with("for sale").and_return(mock_animals_for_sale)
      mock_animals_for_sale.stub!(:by_gender).with("male").and_return(mock_male_animals_for_sale)
      
      @scoped_animal.stub!(:by_gender).with("male").and_return(mock_male_animals)
      mock_male_animals.stub!(:by_status).with("for sale").and_return(mock_male_animals_for_sale)
      
      target = Animal
      params = { "by_status" => "for sale", "by_gender" => "male"}
      @filter.apply(params, target).should == mock_male_animals_for_sale
    end
    
    it "should return the original target when params are nil" do
      mock_animals = mock("Mock Animals")
      target = Animal
      params = nil
      @filter.apply(params, target).should == Animal
    end
    
    it "should return the original target when params are empty" do
      mock_animals = mock("Mock Animals")
      target = Animal
      params = {}
      @filter.apply(params, target).should == Animal
    end
    
    describe "sort filters" do
      it "should apply the sort filter for desc" do
        mock_animals_newest_first = mock("Newest Animals First")
        @scoped_animal.should_receive(:newest_first).and_return(mock_animals_newest_first)
        target = Animal
        params = { "by_created_at" => "desc"}
        @filter.apply(params, target).should == mock_animals_newest_first
      end
      
      it "should apply the sort filter by alias" do
        mock_animals_oldest_first = mock("Oldest Animals First")
        @scoped_animal.should_receive(:oldest_first).and_return(mock_animals_oldest_first)
        target = Animal
        params = { "oldest_first" => true}
        @filter.apply(params, target).should == mock_animals_oldest_first
      end
    end
    
    describe "boolean filter" do
      it "should apply boolean filters when true" do
        mock_active_animals = mock("Active Animals")
        @scoped_animal.should_receive(:active).and_return(mock_active_animals)
        target = Animal
        params = { "active" => true}
        @filter.apply(params, target).should == mock_active_animals
      end
      
      it "should not apply boolean filters when false" do
        @scoped_animal.should_not_receive(:active)
        target = Animal
        params = { "active" => false}
        @filter.apply(params, target).should == @scoped_animal
      end
    end
    
    describe "default filters" do
      
      describe "boolean type" do
        before(:each) do
          @filter.add(:publish, :boolean => true, :default => true)
        end
      
        it "should apply default filters when no other filters are present" do
          mock_published_animals = mock("Published Animals")
          @scoped_animal.should_receive(:publish).and_return(mock_published_animals)
          @filter.apply({}, Animal).should == mock_published_animals
        end
        it "should not apply default filters when other filters are present" do
          mock_active_animals = mock("Active Animals")
          @scoped_animal.should_not_receive(:publish)
          @scoped_animal.should_receive(:active).and_return(mock_active_animals)
          @filter.apply({"active" => true}, Animal).should == mock_active_animals
        end
      end
      
      describe "sort type" do
        before(:each) do
          @filter.add(:post_age, :sort => { :desc => :newest_first, :asc => :oldest_first}, :default => :desc)
        end
      
        it "should apply default filters when no other filters are present" do
          mock_newest_animals = mock("Newest Animals First")
          @scoped_animal.should_receive(:newest_first).and_return(mock_newest_animals)
          @filter.apply({}, Animal).should == mock_newest_animals
        end
      end
      
      describe "that sort" do
        
      end
    end
    
    describe "strict filters" do
      it "should apply strict filters when no other filters are present"
      it "should apply strict fitler when other filters are present"
    end
    
  end
end
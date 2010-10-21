require "test_app/spec/spec_helper.rb"

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/collection_filters'))

TestApp::Application.routes.draw do
  resources :dogs
  resources :animals
end

class Animal < ActiveRecord::Base
  scope :by_gender, lambda { |gender| where(:gender => gender)}
end

class Dog < ActiveRecord::Base
  
end

class AnimalsController < ActionController::Base
  has_filter :by_gender
  has_filter :by_created_at, :sort => {:asc => :newest_first, :desc => :oldest_first}
  has_filter :active, :boolean => true
  def index
    @animals = filtered_collection(Animal)
    render :nothing => true
  end
end

class DogsController < ActionController::Base
  has_filter :by_gender
  has_filter :by_created_at, :sort => {:asc => :newest_first, :desc => :oldest_first}
  has_filter :active, :boolean => true
  def index
    puts params.inspect
    #@dogs = filtered_collection(Dog)
    render :nothing => true
  end
end
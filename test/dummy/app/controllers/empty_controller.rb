class EmptyController < ApplicationController
  %i[index show new edit create update destroy].each do |action|
    define_method(action) { render :text => 'OK' }
  end
end

require 'spec_helper'


describe App do 
	before (:each) do 
		create :app
	end

	it "should have a name" do
		expect { create(:app, name: nil) }.to raise_error
	end
end

module WaitForAjax
	def wait_for_ajax
	  Timeout.timeout(Capybara.default_max_wait_time) do
	    loop do
	      active = page.evaluate_script('jQuery.active')
	      break if active == 0
	    end
	  end
	end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end

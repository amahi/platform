module WaitForAjax
	def wait_for_ajax
	  Timeout.timeout(Capybara.default_wait_time) do
	    loop do
	      active = page.evaluate_script('jQuery.active')
	      break if active == 0
	    end
	  end
	end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end

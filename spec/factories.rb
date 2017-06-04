
FactoryGirl.define do

	factory :user do
		sequence(:login) { |n| "user#{n}" }
		sequence(:name) { |n| "Name #{n}" }
		password "secretpassword"
		password_confirmation "secretpassword"

		# we do not want to create users in the system
		# .......................................................
		# not sure how to disable specific methods in an observer
		# added if staetment in before_create and after_create in
		# UserObserver to check that the environment is not test
		# .......................................................

		# an admin user
		factory :admin do
			admin true
		end
	end

	factory :setting

	factory :share do
		sequence(:path) { |n| "/path #{n}" }
		sequence(:name) { |n| "name #{n}" }
	end
end

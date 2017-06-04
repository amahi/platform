FactoryGirl.define do

	factory :user do
		sequence(:login) { |n| "user#{n}" }
		sequence(:name) { |n| "Name #{n}" }
		password "secretpassword"
		password_confirmation "secretpassword"

		# we do not want to create users in the system
		# so we redefine the before_create and after_create
		# for the user to nil
		UserObserver.class_eval do
			def before_create(user)
				nil
			end
			def after_create(user)
				nil
			end
		end

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

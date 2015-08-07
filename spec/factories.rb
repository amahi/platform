
FactoryGirl.define do

	factory :user do
		sequence(:login) { |n| "user#{n}" }
		sequence(:name) { |n| "Name #{n}" }
		password "secret"
		password_confirmation "secret"

		# we do not want to create users in the system
		before(:create) do |user|
			user.class.skip_callback(:create, :before, ->() { nil })
			user.class.skip_callback(:save, :after, ->() { nil })
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

		before(:create) do |share|
			share.class.define_method(:push_shares) {}
		end
	end
end

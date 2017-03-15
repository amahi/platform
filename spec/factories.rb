
FactoryGirl.define do

	factory :user do
		sequence(:login) { |n| "user#{n}" }
		sequence(:name) { |n| "Name #{n}" }
		password "secret"
		password_confirmation "secret"

		# we do not want to create users in the system
		before(:create) do |u|
			allow(u).to receive(:before_create_hook) { nil }
			# u.stub(:before_create_hook) { nil }
			# u.stub(:after_save_hook) { nil }
			allow(u).to receive(:after_save_hook) { nil }
			# allow(u).to receive(:after_create_hook) { nil }
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

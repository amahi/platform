require 'spec_helper'

RSpec.describe Testapp, type: :model do
  it "migrations are adding all the apps" do
    t = Testapp.where(:identifier=>'php5')
    expect(t.count).to eq(1)
    t = Testapp.where(:identifier=>'normal')
    expect(t.count).to eq(1)
  end

  it "returns correct installer" do
    expect(Testapp.count).to eq(2)
    t = Testapp.where(:identifier=>'normal')
    expect(t[0].get_installer.identifier).to eq('normal')
  end
end

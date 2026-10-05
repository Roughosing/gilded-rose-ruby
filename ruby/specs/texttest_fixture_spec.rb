require 'rspec'
require 'open3'

describe 'text fixture' do
  it 'matches the approved 30-day inventory' do
    stdout, status = Open3.capture2(
      RbConfig.ruby,
      File.expand_path('../texttest_fixture.rb', __dir__),
      '30'
    )

    expect(status).to be_success
    approved = File.read(File.expand_path('texttest_fixture_output.txt', __dir__))
    expect(stdout).to eq(approved)
  end
end

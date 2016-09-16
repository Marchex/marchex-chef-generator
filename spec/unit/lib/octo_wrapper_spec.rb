require_relative '../spec_helper'

describe 'MchxChefGen::octo_wrapper' do
  token = nil
  org = 'marchex-chef'
  repo = 'hostclass_publicftp'
  before (:context) do
    token = ENV['GITHUB_TOKEN']
    expect(token).to_not be_nil
  end
  #let(:nethttp) { double(Net::Http.request) }


  it 'constructs the correct API call'do
    #allow(:nethttp).to receive(:req)
    #expect(:nethttp.req).to be(nil)

    result = MchxChefGen.protect_branch(token, org, repo)
    expect(result.url).to eq('https://github.marchex.com/api/v3/repos/marchex-chef/hostclass_publicftp/branches/master/protection')
  end

  it 'creates a new get repo' do

    result = MchxChefGen.create_repo(token, 'jcarter/foobar1' )
    expect(result).to_not be_nil
  end
end
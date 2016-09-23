require_relative '../spec_helper'

describe 'MchxChefGen::Repository' do
  before (:context) do
  end

  it 'set_basedir returns nil if file doesnt exist' do
    o = MchxChefGen::Repository.new('name', 'path')
    result = o.set_basedir('name')
    expect(result).to be_nil
  end

  it 'set_bassedir returns string if file exists' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return('/site/marchex-chef')
    o = MchxChefGen::Repository.new('name', 'path')
    result = o.set_basedir('name')
    expect(result).to eq('/site/marchex-chef')
  end

  it 'get_repodir returns the correct path' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return('/site/marchex-chef')
    o = MchxChefGen::Repository.new('name', 'path')
    result = o.get_repodir
    expect(result).to eq('/site/marchex-chef/path/name')
  end

  it 'makes the relocate directory if it does not exist' do
    o = MchxChefGen::Repository.new('mchxchefgen_repo', 'cookbooks', '/tmp')
    FileUtils.touch('./mchxchefgen_repo')
    result = o.relocate_repo
    expect(result).to eq(0)
  end
end
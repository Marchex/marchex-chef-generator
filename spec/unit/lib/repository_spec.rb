require_relative '../spec_helper'

describe 'MchxChefGen::Repository' do
  before (:context) do
  end

  it 'set_basedir returns \'.\' if file doesn\' t exist' do
    allow(File).to receive(:exist?).and_return(false)
    o = MchxChefGen::Repository.new('name', 'path')
    result = o.set_basedir('name')
    expect(result).to eq('.')
  end

  it 'set_basedir returns string if file exists' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return('/site/marchex-chef')
    o = MchxChefGen::Repository.new('name', 'path')
    result = o.set_basedir('name')
    expect(result).to eq('/site/marchex-chef')
  end

  it 'get_basedir returns \'.\' if file doesn\'t exist' do
    allow(File).to receive(:exist?).and_return(false)
    o = MchxChefGen::Repository.new('name', 'path')
    expect(o.get_basedir).to eq('.')
  end

  it 'get_basedir returns string if file exists' do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return('/site/marchex-chef')
    o = MchxChefGen::Repository.new('name', 'path')
    expect(o.get_basedir).to eq('/site/marchex-chef')
  end
  
  it 'get_repodir returns the correct path when ' do
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
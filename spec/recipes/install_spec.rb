# encoding: utf-8

require 'spec_helper'

describe 'kafka::_install' do
  let :chef_run do
    r = ChefSpec::SoloRunner.new
    r.converge(*described_recipes)
  end

  let :described_recipes do
    ['kafka::_defaults', described_recipe]
  end

  let :download_path do
    File.join(Chef::Config.file_cache_path, 'kafka_2.9.2-0.8.1.1.tgz')
  end

  it 'downloads remote binary release of Kafka' do
    expect(chef_run).to create_remote_file(download_path)
  end

  it 'validates download' do
    expect(chef_run).not_to run_ruby_block('kafka-validate-download')
    remote_file = chef_run.remote_file(download_path)
    expect(remote_file).to notify('ruby_block[kafka-validate-download]').immediately
  end

  it 'extracts downloaded Kafka archive' do
    expect(chef_run).to run_execute('extract-kafka').with_cwd(File.join(Dir.tmpdir, 'kafka-build'))
  end

  it 'installs extracted Kafka archive' do
    expect(chef_run).to run_execute('install-kafka')
    expect(chef_run).to run_execute('remove-kafka-build')
    link = chef_run.link('/opt/kafka')
    expect(link).to link_to('/opt/kafka-0.8.1.1')
  end
end

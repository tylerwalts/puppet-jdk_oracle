require 'spec_helper'

describe 'jdk_oracle', :type => 'class' do


  context 'When deploying on CentOS' do
    let :facts do {
      :operatingsystem => 'CentOS',
      :osfamily    => 'RedHat',
    }
    end

    context 'with default parameters' do
      it {
        is_expected.to contain_exec( 'get_jdk_installer')
        is_expected.to contain_exec('extract_jdk')
        is_expected.to contain_file('/etc/alternatives/java').with({
          :ensure  => 'link',
        })
        is_expected.to contain_file('/opt/jdk-8').with({
          :ensure  => 'link',
        })
      }
    end

    context 'specifying version 6' do
      let :params do {
        :version => '6',
      } end

      it {
        is_expected.to contain_exec( 'get_jdk_installer')
        is_expected.to contain_exec('extract_jdk')
        is_expected.to contain_file('/opt/jdk-6').with({
          :ensure  => 'link',
        })
      }
    end

    context 'specifying version 7' do
      let :params do {
        :version => '7',
      } end

      it {
        is_expected.to contain_exec( 'get_jdk_installer')
        is_expected.to contain_exec('extract_jdk')
        is_expected.to contain_file('/etc/alternatives/java').with({
          :ensure  => 'link',
        })
        is_expected.to contain_file('/opt/jdk-7').with({
          :ensure  => 'link',
        })
      }
    end

    context 'using custom installation directory' do
      let :params do {
        :install_dir => '/my/path',
        :version => '6',
      } end

      it {
        is_expected.to contain_file("/my/path/jdk-6u45-linux-x64.bin")
        is_expected.to contain_exec('extract_jdk')
      }
    end

    context 'using cache source' do
      let :params do {
        :use_cache => true,
      } end

      it {
        is_expected.to contain_file('/opt/jdk-8u11-linux-x64.tar.gz').with({
          :source => 'puppet:///modules/jdk_oracle/jdk-8u11-linux-x64.tar.gz',
        })
      }
    end

  end

end

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
        is_expected.to contain_exec( 'get_jdk_installer').with_creates("/opt/jdk-8u${::jdk_oracle::default_8_update}-linux-x64.tar.gz")
        is_expected.to contain_file ("/opt/jdk-8u${::jdk_oracle::default_8_update}-linux-x64.tar.gz")
        is_expected.to contain_exec('extract_jdk').with_creates("/opt/jdk1.8.0_${::jdk_oracle::default_8_update}")
        is_expected.to contain_file('/etc/alternatives/java').with({
          :ensure  => 'link',
          :target  => "/opt/jdk1.8.0_${::jdk_oracle::default_8_update}/bin/java",
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
        is_expected.to contain_file("/opt/jdk-6u${::jdk_oracle::default_6_update}-linux-x64.bin")
        is_expected.to contain_exec('extract_jdk').with_creates("/opt/jdk1.6.0_${::jdk_oracle::default_6_update}")
        is_expected.to contain_file('/opt/jdk-6').with({
          :ensure  => 'link',
        })
      }
    end

    context 'specifying version 8' do
      let :params do {
        :version => '8',
      } end

      it {
        is_expected.to contain_exec( 'get_jdk_installer').with_creates("/opt/jdk-7u${::jdk_oracle::default_7_update}-linux-x64.tar.gz")
        is_expected.to contain_file ("/opt/jdk-7u${::jdk_oracle::default_7_update}-linux-x64.tar.gz")
        is_expected.to contain_exec('extract_jdk').with_creates("/opt/jdk1.7.0_${::jdk_oracle::default_7_update}")
        is_expected.to contain_file('/etc/alternatives/java').with({
          :ensure  => 'link',
          :target  => "/opt/jdk1.7.0_${::jdk_oracle::default_7_update}/bin/java",
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
        is_expected.to contain_file("/my/path/jdk-6u${::jdk_oracle::default_6_update}-linux-x64.bin")
        is_expected.to contain_exec('extract_jdk').with_creates("/my/path/jdk1.6.0_${::jdk_oracle::default_6_update}")
      }
    end

    context 'using cache source' do
      let :params do {
        :use_cache => true,
      } end

      it {
        is_expected.to contain_file('/opt/jdk-8u${::jdk_oracle::default_8_update}-linux-x64.tar.gz').with({
          :source => 'puppet:///modules/jdk_oracle/jdk-7u${::jdk_oracle::default_8_update}-linux-x64.tar.gz',
        })
      }
    end

  end

  context 'When deploying on unsupported OS' do
    let :facts do {
      :operatingsystem => 'Vista',
      :osfamily    => 'Windows',
    }
    end

    it { expect { subject }.to raise_error Puppet::Error }
  end

end

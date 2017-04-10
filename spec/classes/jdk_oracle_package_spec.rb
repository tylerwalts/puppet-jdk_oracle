require 'spec_helper'

describe 'jdk_oracle' do
  let(:facts) { {
        :operatingsystem => 'CentOS',
        :osfamily        => 'RedHat'
    }}
  context 'with default values for all parameters' do
    it { should contain_jdk_oracle__install('jdk_oracle')}
    it { is_expected.to contain_Archive('/opt/jdk-8u121-linux-x64.tar.gz')
         .with_source('http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz')
         .with_extract_path('/opt/jdk1.8.0_121/..')
    }

    context 'with jce => true' do
      let(:params) { {
          :jce => true
      }}
      it { is_expected.to contain_Archive('/opt/jce_policy-8.zip')
                              .with_source('http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip')
                              .with_extract_command('unzip -d /opt/jdk1.8.0_121/jre/lib/security -o -j %s')
      }
    end
    context 'with custom download url ' do
      let(:params) { {
          :download_url => 'http://onpremise_webhost/java'
      }}
      it { is_expected.to contain_Archive('/opt/jdk-8u121-linux-x64.tar.gz')
                              .with_source('http://onpremise_webhost/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz')
      }
    end
    context 'with proxy_host' do
      let(:params) { {
          :proxy_host => 'http://proxy_host:3128'
      }}
      it { is_expected.to contain_Archive('/opt/jdk-8u121-linux-x64.tar.gz')
                              .with_proxy_server('http://proxy_host:3128')
      }
    end
    context 'with custom installation path' do
      let(:params) { {
          :install_dir => '/path/to/installation/directory'
      }}
      it { is_expected.to contain_Archive('/path/to/installation/directory/jdk-8u121-linux-x64.tar.gz')
                              .with_extract_path('/path/to/installation/directory/jdk1.8.0_121/..')
      }
    end
    context 'with build and update number' do
      let(:params) { {
          :version_update => '102',
          :version_build => '14'
      }}
      it { is_expected.to contain_Archive('/opt/jdk-8u102-linux-x64.tar.gz')
                              .with_source('http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz')
                              .with_extract_path('/opt/jdk1.8.0_102/..')
      }
    end
  end
end
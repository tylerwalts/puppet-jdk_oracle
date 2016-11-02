# encoding: utf-8
# module_root/spec/acceptance/jdk8_spec.rb
require 'spec_helper_acceptance'

describe 'jre_oracle with default parameters plus another jre8 instance' do
  hosts.each do |node|
    if node['proxyurl']
      str_manifest = <<-EOS
        class { 'jdk_oracle':
          proxy_host => '#{node['proxyurl']}',
          package    => 'jre',
        }
        # setup a jdk instance to compile the jce tester
        jdk_oracle::install { 'jdk8u102':
          version_update => '102',
          version_build  => '14',
          install_dir    => '/usr/java'
        }
        jdk_oracle::install { 'jre8u102':
          package        => 'jre',
          version_update => '102',
          version_build  => '14',
          default_java   => true,
          install_dir    => '/usr/java'
          }
        EOS
    else
      str_manifest = <<-EOS
        class { 'jdk_oracle':
          package => 'jre',
        }
        # setup a jdk instance to compile the jce tester
        jdk_oracle::install { 'jdk8u102':
          version_update => '102',
          version_build  => '14',
          install_dir    => '/usr/java'
        }
        jdk_oracle::install { 'jre8u102':
          package        => 'jre',
          version_update => '102',
          version_build  => '14',
          default_java   => true,
          install_dir    => '/usr/java'
          }
        EOS
    end
    #  puts full_manifest
    let(:manifest) {
      str_manifest
    }

    it 'should run without errors' do
      result = apply_manifest_on(node, manifest, :catch_failures => true, :debug => false)
      expect(result.exit_code).to eq 2
    end

    if node['platform'] =~ /debian/
      alternatives_cmd = 'update-alternatives'
    else
      alternatives_cmd = 'alternatives'
    end

    # default install with no args

    context'should install jre8u11 in /opt' do
      describe file('/opt/jre1.8.0_11') do
          it { should be_directory }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
          it { should be_readable.by('others') }
      end
      it 'should not mess up default alternatives' do
        show_result = shell("#{alternatives_cmd} --display java | grep currently | awk '{ print $5 }'")
        expect(show_result.stdout).not_to match /\/opt\/jre1.8.0_11\/bin\/java/
      end
      it 'Should define a new alternatives for java' do
        show_result = shell("#{alternatives_cmd} --display java | grep ^/opt/jre1.8.0_11/bin/java")
        expect(show_result.stdout).to match /\/opt\/jre1.8.0_11\/bin\/java/
      end
      describe 'Source file should be removed' do
        describe file('/opt/jre-8u11-linux-x64.tar.gz') do
          it { should_not exist }
        end
      end
    end

    # the other install resource:
    context 'should install jre8u102 in /usr/java' do
      describe file('/usr/java/jre1.8.0_102') do
        it { should be_directory }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_readable.by('others') }
      end
      describe 'Source file should be removed' do
        describe file('/usr/java/jre-8u102-linux-x64.tar.gz') do
          it { should_not exist }
        end
      end
      it 'Should set a new default alternatives' do
        show_result = shell("#{alternatives_cmd} --display java | grep currently | awk '{ print $5 }'")
        expect(show_result.stdout).to match /\/usr\/java\/jre1.8.0_102\/bin\/java/
      end
      it 'Should setup a new alternatives option' do
        show_result = shell("#{alternatives_cmd} --display java | grep ^/usr/java/jre1.8.0_102/bin/java")
        expect(show_result.stdout).to match /\/usr\/java\/jre1.8.0_102\/bin\/java/
      end
      describe 'Java profile.d file should be set to newly default java installation' do
        describe file('/etc/profile.d/java.sh') do
          it { should exist }
          its(:content) { should match /export JAVA_HOME=\/usr\/java\/jre1.8.0_102; PATH=\$\{PATH\}:\/usr\/java\/jre1.8.0_102\/bin/ }
        end
      end
    end
  end
end
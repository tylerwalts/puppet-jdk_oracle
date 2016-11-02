# encoding: utf-8
# module_root/spec/acceptance/jdk8_spec.rb
require 'spec_helper_acceptance'

describe 'jdk_oracle with default parameters plus another jdk8 instance' do
  hosts.each do |node|
    if node['proxyurl']
      str_manifest = <<-EOS
        class { 'jdk_oracle':
          proxy_host => '#{node['proxyurl']}'
        }
        jdk_oracle::install { 'jdk8u102':
          version_update => '102',
          version_build  => '14',
          default_java   => true,
          install_dir    => '/usr/java',
          jce            => true
        }
        EOS
    else
      str_manifest = <<-EOS
        class { 'jdk_oracle':
          proxy_host     => undef,
        }
        jdk_oracle::install { 'jdk8u102':
          version_update => '102',
          version_build  => '14',
          default_java   => true,
          install_dir    => '/usr/java',
          jce            => true
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

    context'should install jdk8u11 in /opt' do
      describe file('/opt/jdk1.8.0_11') do
          it { should be_directory }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
          it { should be_readable.by('others') }
      end

      it 'should not mess up default alternatives' do
        show_result = shell("#{alternatives_cmd} --display java | grep currently | awk \'{ print $5 }\'")
        expect(show_result.stdout).not_to match /\/opt\/jdk1.8.0_11\/bin\/java/
      end
      it 'Should define a new alternatives for java' do
        show_result = shell("#{alternatives_cmd} --display java | grep ^/opt/jdk1.8.0_11/bin/java")
        expect(show_result.stdout).to match /\/opt\/jdk1.8.0_11\/bin\/java/
      end
      describe 'Source file should be removed' do
        describe file('/opt/jdk-8u11-linux-x64.tar.gz') do
          it { should_not exist }
        end
      end
      describe 'Should not setup Java Crypto Extentions' do
        shell('cat <<EOF > /Test.java
import javax.crypto.Cipher;

class Test {
  public static void main(String[] args) {
    try {
      int maxKeyLen = Cipher.getMaxAllowedKeyLength("AES");
      System.out.println(maxKeyLen);
    } catch (Exception e){
      System.out.println("Sad world :(");
    }
  }
}
EOF')
        describe command('/opt/jdk1.8.0_11/bin/javac /Test.java') do
          its(:exit_status) { should eq 0 }
        end
        describe command('/opt/jdk1.8.0_11/bin/java -cp / Test') do
          its(:exit_status) { should eq 0 }
          its(:stdout) { should match /128/ }
        end
      end
    end

    # the other install resource:
    context 'should install jdk8u102 in /usr/java' do
      describe file('/usr/java/jdk1.8.0_102') do
        it { should be_directory }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_readable.by('others') }
      end
      describe 'Source file should be removed' do
        describe file('/usr/java/jdk-8u102-linux-x64.tar.gz') do
          it { should_not exist }
        end
      end
      it 'Should set a new default alternatives' do
        show_result = shell("#{alternatives_cmd} --display java | grep currently | awk '{ print $5 }'")
        expect(show_result.stdout).to match /\/usr\/java\/jdk1.8.0_102\/bin\/java/
      end
      it 'Should setup a new alternatives option' do
        show_result = shell("#{alternatives_cmd} --display java | grep ^/usr/java/jdk1.8.0_102/bin/java")
        expect(show_result.stdout).to match /\/usr\/java\/jdk1.8.0_102\/bin\/java/
      end
      describe 'Java profile.d file should be set to newly default java installation' do
        describe file('/etc/profile.d/java.sh') do
          it { should exist }
          its(:content) { should match /export JAVA_HOME=\/usr\/java\/jdk1.8.0_102; PATH=\$\{PATH\}:\/usr\/java\/jdk1.8.0_102\/bin/ }
        end
      end
      describe 'Should setup Java Crypto Extentions' do
        shell('cat <<EOF > /Test.java
import javax.crypto.Cipher;

class Test {
  public static void main(String[] args) {
    try {
      int maxKeyLen = Cipher.getMaxAllowedKeyLength("AES");
      System.out.println(maxKeyLen);
    } catch (Exception e){
      System.out.println("Sad world :(");
    }
  }
}
EOF')
        describe command('javac /Test.java') do
          its(:exit_status) { should eq 0 }
        end
        describe command('java -cp / Test') do
          its(:exit_status) { should eq 0 }
          its(:stdout) { should match /2147483647/ }
        end
      end
    end
  end
end
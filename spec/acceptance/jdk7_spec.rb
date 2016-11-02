# encoding: utf-8
# module_root/spec/acceptance/jdk7_spec.rb
require 'spec_helper_acceptance'

describe 'jdk_oracle to install default jdk7 with JCE' do
  hosts.each do |node|
    if node['proxyurl']
      str_manifest = <<-EOS
        class { 'jdk_oracle':
          proxy_host     => '#{node['proxyurl']}',
          version        => '7',
          version_update => '67',
          version_build  => '01',
          default_java   => true,
          install_dir    => '/usr/java',
          jce            => true
        }
        EOS
    else
      str_manifest = <<-EOS
        class { 'jdk_oracle':
          proxy_host     => undef,
          version        => '7',
          version_update => '67',
          version_build  => '01',
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
      result = apply_manifest_on(node, manifest, :catch_failures => true, :debug => true)
      expect(result.exit_code).to eq 2
    end

    if node['platform'] =~ /debian/
      alternatives_cmd = 'update-alternatives'
    else
      alternatives_cmd = 'alternatives'
    end
    # default install with no args

    context'should install jdk7u67 in /usr/java' do
      describe file('/usr/java/jdk1.7.0_67') do
        it { should be_directory }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_readable.by('others') }
      end

      describe 'Source file should be removed' do
        describe file('/usr/java/jdk-7u67-linux-x64.tar.gz') do
          it { should_not exist }
        end
      end

      it 'Should set a new default alternatives' do
        show_result = shell("#{alternatives_cmd} --display java | grep currently | awk '{ print $5 }'")
        expect(show_result.stdout).to match /\/usr\/java\/jdk1.7.0_67\/bin\/java/
      end
      it 'Should setup a new alternatives option' do
        show_result = shell("#{alternatives_cmd} --display java | grep ^/usr/java/jdk1.7.0_67/bin/java")
        expect(show_result.stdout).to match /\/usr\/java\/jdk1.7.0_67\/bin\/java/
      end

      describe 'Java profile.d file should be set to newly default java installation' do
        describe file('/etc/profile.d/java.sh') do
          it { should exist }
          its(:content) { should match /export JAVA_HOME=\/usr\/java\/jdk1.7.0_67; PATH=\$\{PATH\}:\/usr\/java\/jdk1.7.0_67\/bin/ }
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
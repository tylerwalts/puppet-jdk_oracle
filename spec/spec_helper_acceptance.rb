require 'beaker-rspec'
require 'pry'
require 'pp'

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    # Install module to all hosts
    hosts.each do |host|
      # install_puppet_agent_on(host, { :puppet_gem_version => '3.8.7', :default_action => 'gem_install'})
      config = {
          'main' => {
              'logdir'         => '/var/log/puppet',
              'vardir'         => '/var/lib/puppet',
              'ssldir'         => '/var/lib/puppet/ssl',
              'rundir'         => '/var/run/puppet',
              'basemodulepath' => '/etc/puppet/environments/production/modules'
          },
          'agent' => {
              'environment'      => 'production',
              'hiera_config'     => '/etc/puppet/hiera.yaml',
              'environmentpath'  => '/etc/puppet/environments',
              'strict_variables' => 'true'
              }
          }
      configure_puppet_on(host, config)

      on host, 'mkdir -p /etc/puppet/environments/production/{modules,hieradata,manifests}/'
      install_dev_puppet_module_on(host, :source => module_root,
                                   :module_name => 'jdk_oracle',
                                   :target_module_path => '/etc/puppet/environments/production/modules/')
      # install all modules from fixtures modules directory (spec tests)
      Dir.foreach(module_root + '/spec/fixtures/modules') do |mod|
        if not mod.start_with?('.')
          install_dev_puppet_module_on(host, :source => module_root + '/spec/fixtures/modules/' + mod,
                                       :module_name => mod,
                                       :target_module_path => '/etc/puppet/environments/production/modules/')
        end
      end

    end
  end
end
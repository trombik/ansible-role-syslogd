require "spec_helper"
require "serverspec"

service = "syslogd"
config  = "/etc/syslog.conf"
ports   = [514]
conf_d_dirs = case os[:family]
              when "freebsd"
                %w[/etc/syslog.d /usr/local/etc/syslog.d]
              else
                []
              end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  its(:content) { should match Regexp.escape("Managed by ansible") }
end

conf_d_dirs.each do |d|
  describe file d do
    it { should exist }
    it { should be_directory }
    it { should be_mode 755 }
  end
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/#{service}") do
    it { should exist }
    it { should be_mode 644 }
    it { should be_file }
    its(:content) { should match(/Managed by ansible/) }
  end

  describe file "/usr/local/etc/syslog.d/foo.conf" do
    it { should exist }
    it { should be_mode 775 }
    its(:content) { should match(/Managed by ansible/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it do
      pending "does not work. regex in serverspec is wrong" if os[:family] == "openbsd"
      should be_listening
    end
  end
end

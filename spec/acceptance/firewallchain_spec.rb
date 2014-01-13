require 'spec_helper_acceptance'

describe 'puppet resource firewallchain command:' do
  before :all do
    iptables_flush_all_tables
  end
  context 'creating firewall chains:' do
    it 'applies cleanly' do
      pp = <<-EOS
        firewallchain { 'MY_CHAIN:filter:IPv4':
          ensure  => present,
        }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  context 'adding a firewall rule to a chain:' do
    it 'applies cleanly' do
      pp = <<-EOS
        firewall { '100 my rule':
          chain   => 'MY_CHAIN',
          action  => 'accept',
          proto   => 'tcp',
          dport   => 5000,
        }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  context 'not purge firewallchain chains:' do
    it 'does not purge the rule' do
      pp = <<-EOS
        firewallchain { 'MY_CHAIN:filter:IPv4':
          ensure  => present,
          purge   => false,
          before  => Resources['firewall'],
        }
        resources { 'firewall':
          purge => true,
        }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to_not match(/removed/)
        expect(r.stderr).to eq('')
        expect(r.exit_code).to eq(0)
      end
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    it 'still has the rule' do
      pp = <<-EOS
        firewall { '100 my rule':
          chain   => 'MY_CHAIN',
          action  => 'accept',
          proto   => 'tcp',
          dport   => 5000,
        }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).to eq('')
        expect(r.exit_code).to eq(0)
      end
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end

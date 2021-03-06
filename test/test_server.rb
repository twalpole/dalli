require_relative 'helper'

describe Dalli::Server do
  describe 'hostname parsing' do
    it 'handles unix socket with no weight' do
      s = Dalli::Server.new('/var/run/memcached/sock')
      assert_equal '/var/run/memcached/sock', s.hostname
      assert_equal 1, s.weight
      assert_equal :unix, s.socket_type
    end

    it 'handles unix socket with a weight' do
      s = Dalli::Server.new('/var/run/memcached/sock:2')
      assert_equal '/var/run/memcached/sock', s.hostname
      assert_equal 2, s.weight
      assert_equal :unix, s.socket_type
    end

    it 'handles no port or weight' do
      s = Dalli::Server.new('localhost')
      assert_equal 'localhost', s.hostname
      assert_equal 11211, s.port
      assert_equal 1, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'handles a port, but no weight' do
      s = Dalli::Server.new('localhost:11212')
      assert_equal 'localhost', s.hostname
      assert_equal 11212, s.port
      assert_equal 1, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'handles a port and a weight' do
      s = Dalli::Server.new('localhost:11212:2')
      assert_equal 'localhost', s.hostname
      assert_equal 11212, s.port
      assert_equal 2, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'handles ipv4 addresses' do
      s = Dalli::Server.new('127.0.0.1')
      assert_equal '127.0.0.1', s.hostname
      assert_equal 11211, s.port
      assert_equal 1, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'handles ipv6 addresses' do
      s = Dalli::Server.new('[::1]')
      assert_equal '::1', s.hostname
      assert_equal 11211, s.port
      assert_equal 1, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'handles ipv6 addresses with port' do
      s = Dalli::Server.new('[::1]:11212')
      assert_equal '::1', s.hostname
      assert_equal 11212, s.port
      assert_equal 1, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'handles ipv6 addresses with port and weight' do
      s = Dalli::Server.new('[::1]:11212:2')
      assert_equal '::1', s.hostname
      assert_equal 11212, s.port
      assert_equal 2, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'handles a FQDN' do
      s = Dalli::Server.new('my.fqdn.com')
      assert_equal 'my.fqdn.com', s.hostname
      assert_equal 11211, s.port
      assert_equal 1, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'handles a FQDN with port and weight' do
      s = Dalli::Server.new('my.fqdn.com:11212:2')
      assert_equal 'my.fqdn.com', s.hostname
      assert_equal 11212, s.port
      assert_equal 2, s.weight
      assert_equal :tcp, s.socket_type
    end

    it 'throws an exception if the hostname cannot be parsed' do
      lambda { Dalli::Server.new('[]') }.must_raise Dalli::DalliError
      lambda { Dalli::Server.new('my.fqdn.com:') }.must_raise Dalli::DalliError
      lambda { Dalli::Server.new('my.fqdn.com:11212,:2') }.must_raise Dalli::DalliError
      lambda { Dalli::Server.new('my.fqdn.com:11212:abc') }.must_raise Dalli::DalliError
    end
  end

  describe 'ttl translation' do
    it 'does not translate ttls under 30 days' do
      s = Dalli::Server.new('localhost')
      assert_equal s.send(:sanitize_ttl, 30*24*60*60), 30*24*60*60
    end

    it 'translates ttls over 30 days into timestamps' do
      s = Dalli::Server.new('localhost')
      assert_equal s.send(:sanitize_ttl, 30*24*60*60 + 1), Time.now.to_i + 30*24*60*60+1
    end
  end
end

require 'helper'

class TestAhqdomsys < Test::Unit::TestCase
  def setup
    @user = ""
    @password = ""
  end

  def test_domain_no_password
    d = AHQDomSys::Domain.new "aussiehq.com.au"
    d.api_user = @user
    assert_raise AHQDomSys::AuthError do
      d.available?
    end
  end

  def test_domain_no_username
    d = AHQDomSys::Domain.new "aussiehq.com.au"
    d.api_pw = @password
    assert_raise AHQDomSys::AuthError do
      d.available?
    end
  end

  def test_domain_not_available
    d = AHQDomSys::Domain.new "aussiehq.com.au"
    d.api_user = @user
    d.api_pw = @password
    assert_equal false, d.available?
  end

  def test_random_domain_available
    chars = ("a".."z").to_a
    domain_name = ""
    1.upto(20) { |i| domain_name << chars[rand(chars.size-1)] }

    d = AHQDomSys::Domain.new "#{domain_name}.id.au"
    d.api_user = @user
    d.api_pw = @password
    assert_equal true, d.available?
  end

  def test_domain_query
    d = AHQDomSys::Domain.new "aussiehq.com.au"
    d.api_user = @user
    d.api_pw = @password
    d.query
    assert_equal d.expiry_date, "2011-01-24"
  end
end

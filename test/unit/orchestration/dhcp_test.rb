require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
  end

  def test_host_should_have_dhcp
    if unattended?
      h = hosts(:one)
      assert h.valid?
      assert h.dhcp?
      assert_instance_of Net::DHCP::Record, h.dhcp_record
    end
  end

  def test_host_should_not_have_dhcp
    if unattended?
      h = hosts(:minimal)
      assert h.valid?
      assert_equal false, h.dhcp?
    end
  end

  test "jumpstart parameter generation" do
    h = hosts(:sol10host)
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01").returns("2.3.4.5").once
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01.yourdomain.net").returns("2.3.4.5").once
    #User.current = users(:admin)
    result = h.os.jumpstart_params h, h.model.vendor_class
    assert_equal result, {
      :vendor                => "<Sun-Fire-V210>",
      :install_path          => "/vol/solgi_5.10/sol10_hw0910_sparc",
      :install_server_ip     => "2.3.4.5",
      :install_server_name   => "brsla01",
      :jumpstart_server_path => "2.3.4.5:/vol/jumpstart",
      :root_path_name        => "/vol/solgi_5.10/sol10_hw0910_sparc/Solaris_10/Tools/Boot",
      :root_server_hostname  => "brsla01",
      :root_server_ip        => "2.3.4.5",
      :sysid_server_path     => "2.3.4.5:/vol/jumpstart/sysidcfg/sysidcfg_primary"
    }
  end

end

#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#

require 'openscap/source'
require 'openscap/xccdf/testresult'
require 'common/testcase'

class TestTestResult < OpenSCAP::TestCase
  def test_testresult_new_bad
    source = OpenSCAP::Source.new('../data/xccdf.xml')
    assert !source.nil?
    msg = nil
    begin
      s = OpenSCAP::Xccdf::TestResult.new(source)
      assert false
    rescue OpenSCAP::OpenSCAPError => e
      msg = e.to_s
    end
    assert msg.start_with?("Expected 'TestResult' element while found 'Benchmark'."),
        "Message was: " + msg
  end

  def test_result_create_and_query_properties
    tr = new_tr
    assert tr.id == 'xccdf_org.open-scap_testresult_xccdf_org.ssgproject.content_profile_common',
        "TestResult.id was '#{tr.id}"
    assert tr.profile == 'xccdf_org.ssgproject.content_profile_common',
        "TestResult.profile was '#{tr.profile}'"
    tr.destroy
  end

  def test_result_create_and_query_rr
    tr = new_tr
    assert tr.rr.size == 28
    assert tr.rr.key?('xccdf_org.ssgproject.content_rule_disable_prelink')
    assert tr.rr.key?('xccdf_org.ssgproject.content_rule_no_direct_root_logins')
    assert 'fail' == tr.rr['xccdf_org.ssgproject.content_rule_disable_prelink'].result
    assert 'notchecked' == tr.rr['xccdf_org.ssgproject.content_rule_no_direct_root_logins'].result
    tr.destroy
  end

  def test_override
    tr = new_tr
    rr = tr.rr['xccdf_org.ssgproject.content_rule_disable_prelink']
    assert 'fail' == rr.result
    rr.override!(:new_result => :pass,
                 :time => 'yesterday',
                 :authority => 'John Hacker',
                 :raw_text => 'We are testing prelink on this machine')
    assert 'pass' == rr.result
    tr.destroy()
  end

  private
  def new_tr
    source = OpenSCAP::Source.new('../data/testresult.xml')
    assert !source.nil?
    tr = OpenSCAP::Xccdf::TestResult.new(source)
    source.destroy
    return tr
  end
end
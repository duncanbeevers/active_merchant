require 'test_helper'
require 'digest/md5'

class OfferpalNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  Offerpal.application_id = '153ddfb15ae1e37b7cf004b201c3e3fd'
  Offerpal.secret_key = 'so_secret'

  def setup
    @offerpal = Offerpal::Notification.new(http_raw_data)
  end

  def test_valid_hash?
    assert @offerpal.valid_signature?, "Should be valid signature"
    
    assert !Offerpal::Notification.new('', :gateway => @gateway).valid_signature?, "Signature should be invalid"
  end
  
  def test_accessors
    assert_equal '1234', @offerpal.user_id
    assert_equal '5678', @offerpal.transaction_id
    assert_equal 100, @offerpal.currency
  end
  
  private
  def post_data_without_sig
    {
      :snuid => 1234,
      :currency => 100,
      :id => 5678
    }
  end  
  
  def post_data(data = post_data_without_sig)
    data[:verifier] = Digest::MD5.hexdigest([data[:id], data[:snuid], data[:currency], Offerpal.secret_key].join(":"))
    data
  end
  
  def http_raw_data(params = post_data)
    params.map{|key,value| "#{key}=#{CGI.escape(value.to_s)}"}.join("&")
  end
end

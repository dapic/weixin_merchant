require 'weixin_merchant/model/base'
require 'weixin_merchant/model/order'
require 'weixin_merchant/model/user'
require 'money'

module WeixinMerchant
  module Model
    # response should respond to "result" which returns a Hash
    #   typically it would be a WeixinAuthorize::ResultHandler
    def self.from(response, api = nil)
      raise "Could not handle result including multiple data packages" unless (api || response.result.size == 1)
      result_key = api ? api.to_s : response.result.keys[0]
      case result_key
      when 'user'
        # the payload of "user info" is packed directly, without the layer of "error code"/"error msg"/"result"
        # see http://mp.weixin.qq.com/wiki/14/bb5031008f1494a59c6f71fa0f319c66.html
        # but "ResultHanler" packages the response into a "result" attribute
        self.get_object(User, response.result)
      when 'order'
        self.get_object(Order, response.result[result_key])
      when 'order_list'
        response.result[result_key].map {|h| self.get_object(Order, h) }
      else
        raise "Could not handle Weixin Merchant API response with #{result_key}"
      end
    end

    # Note: the current implementation discards the errcode and errmsg info
    def self.get_object(klass, hash)
      klass.new() {|o| o.info = hash }
    end

  end
end

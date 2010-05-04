module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PaysafeGateway < Gateway
      
      BASE_URL = "https://shops.%s.at.paysafecard.com/pscmerchant/%s"
      OUTPUT_FORMAT = 'xml_v1'
      
      INITIALIZE_TEST_ACTION = 'InitializeMerchantTestDataServlet'
      AUTHORIZE_ACTION = "CreateDispositionServlet"
      
      def initialize(options = {})
        requires!(options, :merchant_id, :currency, :business_type, :pem, :pem_password)
        @options = options
        
        @options[:ca_file] = File.dirname(__FILE__) + '/../../../certs/paysafecard-CA.pem'
        
        super
      end
      
      def initialize_merchant_data
        raise StandardError, "Can only initialize merchant test data in test mode" unless test?
        post = {}
        add_boilerplate_info(post)
        commit(INITIALIZE_TEST_ACTION, post)
      end
      
      def authorize(options = {})
        requires!(options, :transaction_id, :amount, :ok_url, :nok_url)
        post = {}
        add_boilerplate_info(post)
        add_transaction_data(post, options)
        
        commit(AUTHORIZE_ACTION, post)
      end
      
      private

      def add_boilerplate_info(post)
        post[:mid] = @options[:merchant_id]
        post[:outputFormat] = OUTPUT_FORMAT
      end

      def add_transaction_data(post, options)
        post[:currency] = @options[:currency]
        post[:mtid] = options[:transaction_id]
        post[:amount] = '%.2f' % options[:amount]
        post[:okurl] = options[:ok_url]
        post[:nokurl] = options[:nok_url]
        post[:businesstype] = @options[:business_type]
      end

      def commit(action, parameters)
        response = parse( ssl_post( api_url(action), post_data(parameters) ) )

        Response.new(response['errCode'] == '0', response['errMessage'], response,
          :authorization => response["MTID"],
          :test => test?
        )
      end
      
      def post_data(paramaters = {})
        paramaters.map {|key,value| "#{key}=#{CGI.escape(value.to_s)}"}.join("&")
      end

      def parse(xml)
        puts xml
        
        doc = REXML::Document.new(xml)
        hash = doc.root.elements.inject(nil, {}) do |a, node|
          a[node.name] = node.text
          a
        end
        
        puts hash.inspect
        hash
      end

      def api_url(action)
        merchant_id = test? ? 'test' : options[:merchant_id]
        BASE_URL % [ merchant_id, action ]
      end

    end
  end
end
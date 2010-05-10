require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Offerpal
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def complete?
            true
          end 

          def transaction_id
            params['id']
          end

          def user_id
            params['snuid']
          end
          
          def currency
            params['currency'].to_i
          end
          
          def customer_service_credit?
            '1' == params['error']
          end
          
          # Acknowledge the transaction to Offerpal. This method has to be called after a new 
          # apc arrives. Offerpal will verify that all the information we received are correct and will return a 
          # ok or a fail. 
          # 
          # Example:
          # 
          #   def ipn
          #     notify = OfferpalNotification.new(request.raw_post)
          #
          #     if notify.acknowledge 
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def valid_signature?
            params['verifier'] == Digest::MD5.hexdigest([ params['id'], params['snuid'], params['currency'], Offerpal.secret_key ].join(':'))
          end
          alias acknowledge valid_signature?
        end
      end
    end
  end
end

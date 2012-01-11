require 'httmultiparty'
require "whurl_engine/version"

module WhurlEngine
  class Whurl < ActiveRecord::Base
    serialize :request_parameters, Hash
    serialize :request_headers, ::HTTParty::Response::Headers
    serialize :response_headers, ::HTTParty::Response::Headers

    after_initialize :default_values
    before_create :make_request

    def to_param
      hash_key
    end

    def to_s
      http_response.request.to_s
    end

    def to_curl
      ret_str = "curl \"#{url}\" --include --request #{http_method.upcase}"
      headers.each do |k, v|
        ret_str << " -H #{k}:#{v}"
      end
      if ['put', 'post'].include?(http_method.downcase)
        ret_str << " --data \"#{body}\""
      end

      ret_str << " --head" if http_method.downcase == 'head'
      ret_str
    end

    private

    class AnyClient
      include HTTMultiParty
      #debug_output $stderr
    end

    def make_request
      response = AnyClient.send(request_method.downcase,
                                 request_url,
                                 :headers => request_headers.to_hash,
                                 :query => request_parameters.blank? ? nil : request_parameters,
                                 :body => request_body
      )
      self.response_content_type = response.content_type
      self.response_body = response.body
      self.response_headers = response.headers
    end

    def default_values
      generate_hash_key if new_record?
    end

    def generate_hash_key
      upper_bound = 36**6 -1 #max 6 characters
      new_hash_key = rand(upper_bound).to_s(36)
      if new_hash_key.match(/^whurl/)
        generate_hash_key
      else
        self.hash_key = new_hash_key
      end
    end
  end
end
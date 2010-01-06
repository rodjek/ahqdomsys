require 'net/http'
require 'net/https'
require 'uri'
require 'rexml/document'
require 'ahqdomsys/errors'

module AHQDomSys
  module Util
    class APICall
      attr_accessor :username, :password

      def run(args)
        if @password.nil?
          raise AHQDomSys::AuthError, "You must supply your AussieHQ Domain System API password"
        end

        if @username.nil?
          raise AHQDomSys::AuthError, "You must supply your AussieHQ Domain System username"
        end

        args["uid"] = @username
        args["pw"] = @password

        url = URI.parse 'https://domains.aussiehq.com.au/api/'
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == 'https')
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(url.path)
        request.set_form_data(args)
        response = http.request(request)
        doc = REXML::Document.new(response.body)

        yield AHQDomSys::Util::APIResponse.new(doc)
      end
    end

    class APIResponse
      attr_reader :errorcount, :command
      def initialize(doc)
        @errorcount = doc.elements["response/errorcount"].text.to_i
        @command = doc.elements["response/command"].text
        
        @results_array = []
        doc.root.each_element('/response/results/domain') { |domain|
          @results_array << AHQDomSys::Util::APIDomainResult.new(domain)
        }

        @errors_array = []
        doc.root.each_element('/response/errors/error') { |error|
          @errors_array << AHQDomSys::Util::APIError.new(error)
        }
      end

      def results
        @results_array.each { |result|
          yield result
        }
      end

      def errors
        @errors_array.each { |error|
          yield error
        }
      end
    end

    class APIDomainResult
      attr_reader :name, :code, :short, :long
      def initialize(doc)
        @name = doc.elements["name"].text
        @code = doc.elements["status/code"].text.to_i
        @short = doc.elements["status/text"].text
        @long = doc.elements["status/description"].text
        @doc = doc
      end

      def get_val(path)
        @doc.elements[path].text
      end
    end

    class APIError
      attr_reader :domain, :long, :short, :code
      def initialize(doc)
        if doc.text
          @long = doc.text
        end
        if doc.elements["status"]
          @code = doc.elements["status/code"].text.to_i
          @short = doc.elements["status/text"].text
          @long = doc.elements["status/description"].text
        end
        if doc.elements["domain"]
          @domain = doc.elements["domain/name"].text
          @code = doc.elements["domain/status/code"].text.to_i
          @short = doc.elements["domain/status/text"].text
          @long = doc.elements["domain/status/description"].text
        end
      end
    end
  end
end

#f = AHQDomSys::Util::APICall.new
#f.username = user
#f.password = pass
#f.run({'command' => 'check', 'tldlist' => 'id.au,com.au,net.au', 'sld' => 'shasnotehun'}) { |response|
#  puts response.errorcount
#  puts response.command
#  response.results { |domain|
#    puts "#{domain.name}: #{domain.code}"
#    puts "#{domain.name}: #{domain.short}"
#    puts "#{domain.name}: #{domain.long}"
#  }
#  response.errors { |error|
#    puts error.code
#    puts error.long
#    puts error.short
#    puts error.domain
#  }
#}

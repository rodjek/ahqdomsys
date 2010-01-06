require 'ahqdomsys/util'

module AHQDomSys
  class Domain
    attr_accessor :api_user, :api_pw
    attr_accessor :expiry_date
    def initialize(domain)
      @sld = domain.split('.', 2)[0]
      @tld = domain.split('.', 2)[1]
    end

    def available?
      api = AHQDomSys::Util::APICall.new
      api.username = @api_user
      api.password = @api_pw

      code = 0

      api.run({'command' => 'check', 'tld' => @tld, 'sld' => @sld}) { |response|
        response.results { |domain|
          if domain.name == "#{@sld}.#{@tld}"
            code = domain.code
          end
        }
      }

      (code == 210)
    end

    def query
      api = AHQDomSys::Util::APICall.new
      api.username = @api_user
      api.password = @api_pw

      api.run({'command' => "querydomain", 'tld' => @tld, 'sld' => @sld}) { |response|
        response.results { |domain|
          if domain.name == "#{@sld}.#{@tld}" and domain.code == 200
            @expiry_date = domain.get_val('expirydate')
          end
        }
      }
    end
  end
end

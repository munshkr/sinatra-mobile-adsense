require "sinatra/base"
require "open-uri"

module Sinatra
  module MobileAdsense

    module Helpers
      def mobile_adsense(options)
        raise ArgumentError, ":client option must be defined" unless options[:client]

        # TODO Should be timezone aware?
        dt = "%.0f" % (1000 * Time.now.to_f)
        user_agent = request.user_agent

        options = options.dup
        unless options[:client] =~ /^ca\-mb\-/
          options[:client] = "ca-mb-#{ options[:client] }" 
        end
        options = {
          :ad_type => "text_image",
          :channel => "",
          :dt => dt,
          :format => "mobile_single",
          :ip => request.ip,
          :markup => "xhtml",
          :oe => "utf8",
          :output => "xhtml",
          :ref => (request.referer || ""),
          :url => request.url,
          :useragent => user_agent
        }.merge(google_screen_res).merge(google_muid).merge(google_via_and_accept(user_agent)).merge(options)

        ad_url = "http://pagead2.googlesyndication.com/pagead/ads?"
        ad_url += options.map { |k, v|
          v = google_color(v, dt) if k =~ /color_/
          "#{ k }=#{ ERB::Util.u(v) }"
        }.join("&")

        begin
          result = URI(ad_url).read
        rescue StandardError, Timeout::Error
          ""
        end
      end
    end

    def self.registered(app)
      app.helpers MobileAdsense::Helpers
    end


    def google_color(color, time)
      color_array = color.split(",")
      color_array[time.to_i % color_array.size]
    end

    def google_screen_res
      screen_res =
        request.env["HTTP_UA_PIXELS"] ||
        request.env["HTTP_X_UP_DEVCAP_SCREENPIXELS"] ||
        request.env["HTTP_X_JPHONE_DISPLAY"] ||
        ""
      res_array = screen_res.split(/[x,*]/)
      (res_array.size == 2) ? { :u_w => res_array[0], :u_h => res_array[1] } : {}
    end

    def google_muid
      muid =
        request.env["HTTP_X_DCMGUID"] ||
        request.env["HTTP_X_UP_SUBNO"] ||
        request.env["HTTP_X_JPHONE_UID"] ||
        request.env["HTTP_X_EM_UID"]
      muid ? { :muid => muid } : {}
    end

    def google_via_and_accept(ua)
      return {} if ua
      via_and_accept = {}
      via = request.env["HTTP_VIA"]
      via_and_accept[:via] = request.env["HTTP_VIA"] if via
      accept = request.env["HTTP_ACCEPT"]
      via_and_accept[:accept] = request.env["HTTP_ACCEPT"] if accept
      via_and_accept
    end
  end

  register MobileAdsense
end

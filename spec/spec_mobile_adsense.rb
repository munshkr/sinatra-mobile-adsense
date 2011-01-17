require "rubygems"
gem "rspec", ">= 2.0"

require "rspec"
require "sinatra"
require "rack/test"
require "webmock"

require "sinatra/mobile_adsense"

RSpec.configure do |config|
  config.include WebMock::API
  WebMock.disable_net_connect!
end

set :environment, :test

class Rack::Request
  def secure?
    (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) == 'https'
  end
end


describe "MobileAdsense" do
  include Rack::Test::Methods
  include Sinatra::MobileAdsense
  include Sinatra::MobileAdsense::Helpers

  attr_accessor :request

  def app
    Sinatra::Application
  end

  def reset_request
    get "/"
    @request = last_request
  end

  before { reset_request }

  describe "::mobile_adsense" do
    def set_stub_request(query = {})
      stub_request(:get, "pagead2.googlesyndication.com/pagead/ads").
        with(:query => {
          :client => "ca-mb-pub-1234567890",
          :ad_type => "text_image",
          :channel => "",
          :dt => "1287840160591",
          :format => "mobile_single",
          :ip => @request.ip,
          :markup => "xhtml",
          :oe => "utf8",
          :output => "xhtml",
          :ref => "/",
          :url => @request.url,
          :useragent => @request.user_agent
        }.merge(query)).
        to_return :body => @ad_output
    end

    before { @ad_output = "<adsense>" }

    before do
      Time.stub_chain :now, :to_f => 1287840160.59053
    end

    it "should need 'client' option" do
      set_stub_request
      lambda { mobile_adsense(:client => "pub-1234567890") }.should_not raise_error(ArgumentError)
      lambda { mobile_adsense(:foo => "var", :client => "pub-1234567890") }.should_not raise_error(ArgumentError)
      lambda { mobile_adsense }.should raise_error(ArgumentError)
      lambda { mobile_adsense(:foo => "var") }.should raise_error(ArgumentError)
    end

    it "should return the adsense's output" do
      set_stub_request
      mobile_adsense(:client => "pub-1234567890").should == @ad_output
      mobile_adsense(:client => "ca-mb-pub-1234567890").should == @ad_output
    end

    it "should consider passed paramerters" do
      set_stub_request :color_border => "ffffff"
      mobile_adsense(:client => "pub-1234567890", :color_border => "ffffff").should == @ad_output
    end

    context "when an error happens while requesting for google" do
      it "should return empty string" do
        stub_request(:get, %r!pagead2.googlesyndication.com/pagead/ads!).to_timeout
        lambda { mobile_adsense(:client => "pub-1234567890") }.should_not raise_error
        mobile_adsense(:client => "pub-1234567890").should == ""
      end
    end
  end

  describe "::google_color" do
    it "should return color code" do
      google_color("ffffff,cccccc", 0).should == "ffffff"
      google_color("ffffff,cccccc", 1).should == "cccccc"
      google_color("ffffff,cccccc", 2).should == "ffffff"
    end
  end

  describe "::google_screen_res" do
    it "should return 'u_w' and 'u_h' parameters" do
      @request.env["HTTP_UA_PIXELS"] = "240x320"
      google_screen_res.should == { :u_w => "240", :u_h => "320" }

      reset_request
      @request.env["HTTP_X_UP_DEVCAP_SCREENPIXELS"] = "200,300"
      google_screen_res.should == { :u_w => "200", :u_h => "300" }

      reset_request
      @request.env["HTTP_X_JPHONE_DISPLAY"] = "250*330"
      google_screen_res.should == { :u_w => "250", :u_h => "330" }

      reset_request
      @request.env["HTTP_UA_PIXELS"] = "240"
      google_screen_res.should == {}

      reset_request
      google_screen_res.should == {}
    end
  end

  describe "::google_muid" do
    it "should return 'muid' parameter" do
      @request.env["HTTP_X_DCMGUID"] = "XXXXX000000"
      google_muid.should == { :muid => "XXXXX000000" }

      reset_request
      @request.env["HTTP_X_UP_SUBNO"] = "00000000000000_mj.ezweb.ne.jp"
      google_muid.should == { :muid => "00000000000000_mj.ezweb.ne.jp" }

      reset_request
      @request.env["HTTP_X_JPHONE_UID"] = "aaaaaaaaaaaaaaaa"
      google_muid.should == { :muid => "aaaaaaaaaaaaaaaa" }

      reset_request
      @request.env["HTTP_X_EM_UID"] = "bbbbbbbbbbbbbbbb"
      google_muid.should == { :muid => "bbbbbbbbbbbbbbbb" }

      reset_request
      google_muid.should == {}
    end
  end

  describe "::google_via_and_accept" do
    it "should return 'via' and 'accept' parameters when user agent is undefined" do
      @request.env["HTTP_VIA"] = "via"
      google_via_and_accept(nil).should == { :via => "via" }

      reset_request
      @request.env["HTTP_ACCEPT"] = "accept"
      google_via_and_accept(nil).should == { :accept => "accept" }

      reset_request
      @request.env["HTTP_VIA"] = "via!"
      @request.env["HTTP_ACCEPT"] = "accept!"
      google_via_and_accept(nil).should == { :via => "via!", :accept => "accept!" }

      reset_request
      google_via_and_accept("ua").should == {}

      reset_request
      @request.env["HTTP_VIA"] = "via!!"
      @request.env["HTTP_ACCEPT"] = "accept!!"
      google_via_and_accept("ua").should == {}
    end
  end
end

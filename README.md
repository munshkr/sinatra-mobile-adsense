# Mobile Adsense for Sinatra #

A Sinatra extension that provides a helper to show Google Adsense for Mobile.

## Usage ##

To use it, just use the `mobile_adsense` helper in your application template. A `:client` option must be provided:

    <%= mobile_adsense :client => 'pub-1234567890' %>

And that's it! You can pass any options.

    <%= mobile_adsense :client => 'pub-1234567890', :format => 'mobile_double', :color_border => 'FFFFFF', :color_bg => 'FFFFFF' %>

The `mobile_adsense` helper accesses Google server to get advertisements. If an error occurs doing the request, it returns an empty string. Exceptions are **not** raised.

## Install ##

You can install manually the gem:

    $ gem install sinatra-mobile-adsense

Or, if you use Bundler, add this line on your Gemfile:

    gem "sinatra-mobile-adsense", :git => "git://github.com/munshkr/sinatra-mobile-adsense.git"

and run `bundle install`.

Finally, register the extension in your Sinatra application:

    class MyApp < Sinatra::Base
      register Sinatra::MobileAdsense
      
      # Your app code goes here
    end

## Legal ##

This extension is mostly based on the Rails [plugin](http://github.com/milk1000cc/mobile_adsense) by milk1000cc.

Copyright (c) 2011 milk1000cc, munshkr
Released under the MIT license

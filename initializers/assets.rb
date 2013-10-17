require 'less'
require 'sinatra/assetpack'

module Initializers
  module Assets
    def self.included(base)
      base.class_eval do
        register Sinatra::AssetPack

        # Assets

        Less.paths << "app/css"
        assets do
          serve '/js', from: 'public/js'
          js :app, '/js/app.js', [
            '/js/libs/jquery-1.7.2.min.js',
            '/js/libs/underscore-min.js',
            '/js/libs/backbone-min.js',
            '/js/libs/modernizr-2.5.3-respond-1.1.0.min.js',
            '/js/libs/bootstrap/transition.js',
            '/js/libs/bootstrap/alert.js',
            '/js/libs/bootstrap/button.js',
            '/js/libs/bootstrap/carousel.js',
            '/js/libs/bootstrap/collapse.js',
            '/js/libs/bootstrap/dropdown.js',
            '/js/libs/bootstrap/modal.js',
            '/js/libs/bootstrap/tooltip.js',
            '/js/libs/bootstrap/popover.js',
            '/js/libs/bootstrap/scrollspy.js',
            '/js/libs/bootstrap/tab.js',
            '/js/libs/bootstrap/typeahead.js',
            '/js/libs/moment.min.js',
            '/js/libs/jquery-ui-1.8.23.min.js',
            '/js/libs/daterangepicker.jQuery.compressed.js',
            '/js/sticky.js'
          ]
          css :main, '/css/styles.css', [
            '/css/style.css',
            '/css/jquery.ui.1.8.16.ie.css',
            '/css/jquery-ui-1.8.16.custom.css',
            '/css/ui.daterangepicker.css',
          ]
          js_compression :jsmin
          css_compression :simple
        end
      end

    end
  end
end

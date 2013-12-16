require 'sinatra'
require 'facets'
require 'rabl'
require 'lims-history-app/context'

Rabl.register!
Rabl.configure do |config|
  config.include_child_root = false
end

module Lims
  module HistoryApp
    class Server < Sinatra::Base
     
      helpers do
        def filtered_query_parameters
          request.params.mash do |k,v|
            [k, Rack::Utils.escape_html(v)]
          end
        end

        def url_for(target)
          @resource_page.url_for(target)
        end

        def next_page?
          @resource_page.next_page
        end

        def previous_page?
          @resource_page.previous_page
        end
      end

      before do
        content_type "application/json" 
        @query_parameters = filtered_query_parameters
        @context = settings.context_service.new_context(request)
      end

      before '/' do
        @root_resource = @context.for_root
      end

      before '/:model' do
        @resource_page = @context.for_model(params[:model], @query_parameters)
      end

      before '/:model/:uuid' do
        @resource_page = @context.for_uuid(params[:model], params[:uuid], @query_parameters)
      end

      get '/:model/?:uuid?' do
        @objects = @resource_page.call
        rabl :resources, :format => :json
      end

      get '/' do
        @root_objects = @root_resource.call
        rabl :root, :format => :json
      end
    end
  end
end

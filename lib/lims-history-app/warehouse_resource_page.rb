require 'lims-history-app/resource'

module Lims::HistoryApp
  class WarehouseResourcePage
    include Resource

    # @param [Context] context
    # @param [String] model_name
    # @param [Sequel::Dataset] dataset
    def initialize(context, model_name, dataset)
      super(context)
      @dataset = dataset
      @model_name = model_name
      @number_per_page = context.number_of_result_per_page
    end

    # @return [Array]
    def call
      offset = (page - 1) * @number_per_page
      @total = @dataset.unlimited.count
      @dataset.offset(offset).all
    end

    # @param [String,Symbol] target
    def url_for(target)
      if target =~ /^\w{8}-(\w{4}-?){3}-\w{12}$/
        url = @context.request.base_url
        url << "/#{@model_name}/#{target}"
      else
        page_number = send(target)
        url = "#{@context.request.url}"
        url.gsub!(/\??&?page=\d+/, '')
        url << (url =~ /\?/ ? "&" : "?")
        url << "page=#{page_number}"
      end
    end

    def name
      @model_name
    end

    def attributes
      @dataset.columns - private_attributes
    end

    private

    def page
      @page ||= (@context.request.params.delete("page") || 1).to_i
    end

    def private_attributes
      [primary_key]
    end

    def primary_key
      :internal_id
    end


    module Pagination
      # @return [Integer]
      def first_page
        1 
      end

      # @return [Integer]
      def last_page
        (@total.to_f / @number_per_page).ceil
      end

      # @return [Integer,Nil]
      def next_page
        page + 1 unless page == last_page
      end

      # @return [Integer,Nil]
      def previous_page
        page - 1 unless page == 1
      end
    end
    include Pagination
  end
end

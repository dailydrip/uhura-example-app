# frozen_string_literal: true

module ErrorHelper
  def flash_error(error)
    err_val = JSON.parse(error.to_s)['error']
    flash[:error] =  err_val['message'] || err_val['error']
  end

  #TODO: Put this error parsing in uhura_client
  def flash_error_status(error_str)
    doc = Nokogiri::HTML(error_str)
    flash.discard
    # When an exception is caught by a Rails controller, it displays a one-liner in the only h2 section.
    flash[:error] = "Status Error: #{doc.at('h2').to_str.strip}"
  end
end

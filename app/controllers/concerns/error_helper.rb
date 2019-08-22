# frozen_string_literal: true

module ErrorHelper

  def error_to_s(error)
    if error.class.eql?(String)
      error
    else
      err_val = JSON.parse(error.to_s)
      if err_val['error'] && err_val['error']['message']
        msg = err_val['error']['message']['msg']
        details = err_val['error']['message']['error'].join(', ')
        "#{msg} - #{details}"
      end
    end
  end

  def flash_error(error)
    flash.discard
    flash[:error] =  error_to_s(error)
  end

  def flash_error_status(error_str)
    doc = Nokogiri::HTML(error_str)
    flash.discard
    # When an exception is caught by a Rails controller, it displays a one-liner in the only h2 section.
    if doc&.at('h2')
      flash[:error] = "Status ErrorX: #{doc&.at('h2')&.to_str&.strip}"
    else
      # Display raw error string
      flash[:error] = error_str
    end
  end
end

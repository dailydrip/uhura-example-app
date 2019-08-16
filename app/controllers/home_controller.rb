# frozen_string_literal: true
require "ostruct"

class HomeController < ApplicationController
  include ErrorHelper
  skip_before_action :verify_authenticity_token

  def templates
    [
        OpenStruct.new(id: 'd-05d33214e6994b01b577602036bfa9f5', name: 'Sendgrid Template with 1 Section'),
        OpenStruct.new(id: 'd-9cb910a98ffc4f99b9b5952b5d2c7f6b', name: 'Sendgrid Template with 2 Sections'),
        OpenStruct.new(id: 'd-8eeef84db24d478ab0a5d30e35e7211b', name: 'Sendgrid Template with 3 Sections')
    ]
  end

  def index
    @email_status = params['email_status']
    if params['email_status'] && params['email_status']['errors']
      flash[:error] = JSON.parse(params['email_status']['errors'].to_json)
      @email_status = 'ERROR'
    end
    @sms_status = params['sms_status']
    @message_id = params['message_id']
    @sendgrid_templates = templates
  end

  def status_ajax
    client = UhuraClient::MessageClient.new(
        api_key: ENV['UHURA_API_KEY'], team_id: ENV['UHURA_TEAM_ID'], public_token: ENV['UHURA_PUBLIC_TOKEN'])

    render json: {status: client.status_of(UhuraClient::Message.new(id: params[:message_id])) }
  end

  def status
    sleep 1.second
    client = UhuraClient::MessageClient.new(
      api_key: ENV['UHURA_API_KEY'], team_id: ENV['UHURA_TEAM_ID'], public_token: ENV['UHURA_PUBLIC_TOKEN'])

    begin
      response = client.status_of(UhuraClient::Message.new(id: @message.id))
      response
    rescue StandardError => error
      flash_error_status(error.to_s)
    end
  end

  def email_message_hash
    email_message = {
        "header": params[:header],
        "section1": params[:section1],
        "button": params[:button]
    }
    email_message[:section2] = params[:section2] if params[:section2]
    email_message[:section3] = params[:section3] if params[:section3]
    email_message
  end

  def text_to_array(text)
    text.split(',').map { |i| i.strip }
  end

  def email_options_hash
    {
        "cc": text_to_array(params[:cc]),
        "bcc": text_to_array(params[:bcc]),
        "reply_to": text_to_array(params[:reply_to]),
        "send_at": text_to_array(params[:send_at]),
        "batch_id": text_to_array(params[:batch_id])
    }
  end

  def send_message
    # Create message with SMS and Email content
    @message = UhuraClient::Message.new(
      public_token: ENV['UHURA_PUBLIC_TOKEN'],
      receiver_sso_id: params[:receiver_sso_id],
      email_subject: params[:email_subject],
      email_message: email_message_hash,
      email_options: email_options_hash,
      template_id: params[:template_id],
      sms_message: params[:sms_message],
      id: nil
      )

    client = UhuraClient::MessageClient.new(
        api_key: ENV['UHURA_API_KEY'],
        team_id: ENV['UHURA_TEAM_ID'],
        public_token: ENV['UHURA_PUBLIC_TOKEN']
    )

    begin
      response = client.send_message(@message)
      @message.id = response['message_id']
      flash[:success] =  'Success!'
    rescue StandardError => error
      # err_val = JSON.parse(error.to_s)['error']
      # flash[:error] =  err_val['message'] || err_val['error']
      flash_error(error)
    end
    email_sms_status = status
    redirect_to controller: 'home', action: 'index',
                email_status: email_sms_status['sendgrid_msg_status'],
                sms_status: email_sms_status['clearstream_msg_status'],
                message_id: @message.id
  end
end
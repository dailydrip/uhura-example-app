# frozen_string_literal: true
require "ostruct"

class HomeController < ApplicationController
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
    @client_id = params['client_id']
    @sendgrid_templates = templates
  end

  def status
    sleep 1.second
    ## This is the way how we can get the status of a  message
    client = UhuraClient::MessageClient.new(
      api_key: "b1dcc4b8287a82fe8889", team_id: "1", public_token: "42c50c442ee3ca01378e")

    client.status_of(UhuraClient::Message.new(id: @message.client_id))
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

  def send_message
    # Create message with SMS and Email content
    @message = UhuraClient::Message.new(
      public_token: "42c50c442ee3ca01378e",
      receiver_sso_id: params[:receiver_sso_id],
      email_subject: params[:email_subject],
      email_message: email_message_hash,
      template_id: params[:template_id],
      sms_message: params[:sms_message],
      client_id: SecureRandom.uuid
      )

    client = UhuraClient::MessageClient.new(
      api_key: "b1dcc4b8287a82fe8889",
      team_id: "1"
    )
    begin
      client.send_message(@message)
      flash[:success] =  'Success!'
    rescue StandardError => error
      flash[:error] =  JSON.parse(error.to_s)['error']['message']
    end
    email_sms_status = status
    redirect_to controller: 'home', action: 'index',
                email_status: email_sms_status['sendgrid_msg_status'],
                sms_status: email_sms_status['clearstream_msg_status'],
                client_id: @message.client_id
  end
end
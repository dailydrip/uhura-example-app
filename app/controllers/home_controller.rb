# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index

  end

  def status
    ## This is the way how we can get the status of a  message
    client = UhuraClient::MessageClient.new(
      api_key: "b1dcc4b8287a82fe8889", team_id: "1", public_token: "42c50c442ee3ca01378e")

    client.status_of(UhuraClient::Message.new(id: "1"))
  end

  def send_message
    # Create message with SMS and Email content
    message = UhuraClient::Message.new(
      public_token: "42c50c442ee3ca01378e",
      receiver_sso_id: params[:receiver_sso_id],
      email_subject: params[:email_subject],
      email_message: {
            "header": params[:header],
            "section1": params[:section1],
            "button": params[:button]
      },
      template_id: params[:template_id],
      sms_message: params[:sms_message]
      )

    client = UhuraClient::MessageClient.new(
      api_key: "b1dcc4b8287a82fe8889",
      team_id: "1"
    )
    begin
      client.send_message(message)
      flash[:success] =  'Success!'
    rescue StandardError => error
      flash[:error] =  JSON.parse(error.to_s)['error']['message']
    end
    redirect_to :root
  end
end
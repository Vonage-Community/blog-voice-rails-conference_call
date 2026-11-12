# Handles the Voice API webhooks for the Vonage number linked to this application.
class ConferenceController < ApplicationController
  # Every caller who is sent to the same conversation name joins the same conference.
  # Names are scoped to your Vonage application.
  CONFERENCE_NAME = "vonage-conference"

  # Vonage requests this URL when someone calls your Vonage number.
  # The JSON response is a Call Control Object (NCCO): a list of actions Vonage runs in order.
  def answer
    render json: [
      { action: "talk", text: "Welcome to this Vonage conference call" },
      { action: "conversation", name: CONFERENCE_NAME }
    ]
  end

  # Vonage sends call status updates here (started, ringing, answered, completed).
  # Rails already logs the request parameters, so this action only needs to acknowledge them.
  def event
    head :ok
  end
end

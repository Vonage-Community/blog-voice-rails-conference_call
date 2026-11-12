require "test_helper"

class ConferenceControllerTest < ActionDispatch::IntegrationTest
  EXPECTED_NCCO = [
    { "action" => "talk", "text" => "Welcome to this Vonage conference call" },
    { "action" => "conversation", "name" => "vonage-conference" }
  ].freeze

  test "answer returns an NCCO that greets the caller and joins the conference" do
    get "/webhooks/answer", params: { from: "447700900000", to: "447700900001" }

    assert_response :ok
    assert_equal "application/json", response.media_type
    assert_equal EXPECTED_NCCO, response.parsed_body
  end

  test "answer also accepts POST requests" do
    post "/webhooks/answer", params: { from: "447700900000", to: "447700900001" }, as: :json

    assert_response :ok
    assert_equal EXPECTED_NCCO, response.parsed_body
  end

  test "event acknowledges call status updates" do
    post "/webhooks/event", params: { status: "completed", uuid: "aaaa-bbbb" }, as: :json

    assert_response :ok
    assert_empty response.body
  end
end

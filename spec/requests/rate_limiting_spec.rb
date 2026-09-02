require 'rails_helper'

# rack-attack keeps its counters in a cache shared across the process, so each
# example resets it to stay independent of the others.
RSpec.describe "Rate limiting", type: :request do
  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store.clear
  end

  after { Rack::Attack.cache.store.clear }

  let(:user) { create(:user, password: "password123") }

  def attempt_sign_in(email:, password: "wrong-password", ip: "1.2.3.4")
    post user_session_path,
         params: { user: { email: email, password: password } },
         env: { "REMOTE_ADDR" => ip }
  end

  it "throttles repeated failed sign-ins from one IP" do
    10.times { attempt_sign_in(email: user.email) }
    expect(response).not_to have_http_status(:too_many_requests)

    attempt_sign_in(email: user.email)
    expect(response).to have_http_status(:too_many_requests)
    expect(response.headers["Retry-After"]).to be_present
  end

  it "throttles one email even when the attacker rotates IP" do
    10.times { |i| attempt_sign_in(email: user.email, ip: "10.0.0.#{i}") }

    attempt_sign_in(email: user.email, ip: "172.16.5.5")
    expect(response).to have_http_status(:too_many_requests)
  end

  it "counts the same email regardless of casing or padding" do
    10.times { attempt_sign_in(email: "  #{user.email.upcase}  ") }

    attempt_sign_in(email: user.email)
    expect(response).to have_http_status(:too_many_requests)
  end

  it "throttles password reset requests" do
    5.times do
      post user_password_path,
           params: { user: { email: user.email } },
           env: { "REMOTE_ADDR" => "5.6.7.8" }
    end

    post user_password_path,
         params: { user: { email: user.email } },
         env: { "REMOTE_ADDR" => "5.6.7.8" }
    expect(response).to have_http_status(:too_many_requests)
  end

  it "never throttles the health check" do
    400.times { get "/up", env: { "REMOTE_ADDR" => "9.9.9.9" } }
    expect(response).to have_http_status(:success)
  end

  it "lets a legitimate sign-in through" do
    attempt_sign_in(email: user.email, password: "password123")
    expect(response).to redirect_to(root_path)
  end
end

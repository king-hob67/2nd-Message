require "sinatra"
require "dotenv/load"
require "net/http"
require "json"
require "twilio-ruby"

# Store user data in an array
users = []

# Store messages in an array
messages = []

# Function to add user to the array
def add_user(username, password, email, phone_number)
  users.push({ username: username, password: password, email: email, phone_number: phone_number })
end

# Function to add message to the array
def add_message(message, username)
  messages.push({ message: message, username: username })
end

# Function to display messages
def display_messages
  messages.each do |message|
    puts "#{message[:username]}: #{message[:message]}"
  end
end

# Admin access
admin_username = "0826"
admin_password = "2608"

# Facebook integration
facebook_app_id = "YOUR_APP_ID"
facebook_app_secret = "YOUR_APP_SECRET"

# Google integration
google_api_key = "YOUR_API_KEY"

# Twilio integration
twilio_account_sid = "YOUR_ACCOUNT_SID"
twilio_auth_token = "YOUR_AUTH_TOKEN"
twilio_client = Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token)

# Self-improvement function
def self_improve
  # Use Google API to learn and improve every hour
  uri = URI("https://www.googleapis.com/customsearch/v1?key=#{google_api_key}&cx=YOUR_CSE_ID&q=web+development+tutorials")
  response = Net::HTTP.get_response(uri)
  json = JSON.parse(response.body)
  # Analyze and learn from the search results
  # Apply the learned knowledge to improve the website's code
end

get "/" do
  # Display creator name
  erb :index, layout: :layout
end

post "/signup" do
  # Get user data from form
  username = params["username"]
  password = params["password"]
  email = params["email"]
  phone_number = params["phone_number"]

  # Add user to array
  add_user(username, password, email, phone_number)

  # Redirect to login page
  redirect "/login"
end

get "/login" do
  # Display login form
  erb :login, layout: :layout
end

post "/login" do
  # Get username and password from form
  username = params["username"]
  password = params["password"]

  # Check if username and password are correct
  users.each do |user|
    if user[:username] == username && user[:password] == password
      # Set user logged in session
      session["user_logged_in"] = true
      session["username"] = username

      # Redirect to message page
      redirect "/messages"
    end
  end

  # Display error message
  erb :error, layout: :layout
end

get "/messages" do
  # Check if user is logged in
  if session["user_logged_in"]
    # Display message form and messages
    erb :messages, layout: :layout
  else
    # Redirect to login page
    redirect "/login"
  end
end

post "/message" do
  # Get message from form
  message = params["message"]

  # Add message to array
  add_message(message, session["username"])

  # Redirect to message page
  redirect "/messages"
end

get "/facebook/login" do
  # Redirect to Facebook login page
  redirect "https://www.facebook.com/v2.12/dialog/oauth?client_id=#{facebook_app_id}&redirect_uri=#{request.url}&scope=email"
end

get "/facebook/callback" do
  # Get code from Facebook
  code = params["code"]

  # Exchange code for access token
  access_token = exchange_code(code)

  # Get user data from Facebook
  user_data = get_user_data(access_token)

  # Add user to array
  add_user(user_data["name"], user_data["email"], user_data["email"], "")

  # Redirect to message page
  redirect "/messages"
end

def exchange_code(code)
  # Exchange code for access token
  uri = URI("https://graph.facebook.com/v2.12/oauth/access_token?client_id=#{facebook_app_id}&redirect_uri=#{request.url}&client_secret=#{facebook_app_secret}&code=#{code}")
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)["access_token"]
end

def get_user_data(access_token)
  # Get user data from Facebook
  uri = URI("https://graph.facebook.com/v2.12/me?fields=name,email&access_token=#{access_token}")
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end

get "/admin" do
  # Check if admin is

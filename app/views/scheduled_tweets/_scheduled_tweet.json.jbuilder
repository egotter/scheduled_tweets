json.extract! scheduled_tweet, :id, :uid, :text, :properties, :created_at, :updated_at
json.url scheduled_tweet_url(scheduled_tweet, format: :json)

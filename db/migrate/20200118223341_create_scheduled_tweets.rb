class CreateScheduledTweets < ActiveRecord::Migration[6.0]
  def change
    create_table :scheduled_tweets do |t|
      t.bigint :user_id, null: false
      t.bigint :tweet_id
      t.text :text
      t.json :properties
      t.datetime :time, null: false
      t.string :repeat_type, null: true
      t.datetime :published_at

      t.timestamps null: false

      t.index :user_id
    end
  end
end

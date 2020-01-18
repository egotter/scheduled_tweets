class CreateScheduledTweets < ActiveRecord::Migration[6.0]
  def change
    create_table :scheduled_tweets do |t|
      t.bigint :uid
      t.text :text
      t.json :properties

      t.timestamps
    end
  end
end

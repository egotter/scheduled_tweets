require "application_system_test_case"

class ScheduledTweetsTest < ApplicationSystemTestCase
  setup do
    @scheduled_tweet = scheduled_tweets(:one)
  end

  test "visiting the index" do
    visit scheduled_tweets_url
    assert_selector "h1", text: "Scheduled Tweets"
  end

  test "creating a Scheduled tweet" do
    visit scheduled_tweets_url
    click_on "New Scheduled Tweet"

    fill_in "Properties", with: @scheduled_tweet.properties
    fill_in "Text", with: @scheduled_tweet.text
    fill_in "Uid", with: @scheduled_tweet.uid
    click_on "Create Scheduled tweet"

    assert_text "Scheduled tweet was successfully created"
    click_on "Back"
  end

  test "updating a Scheduled tweet" do
    visit scheduled_tweets_url
    click_on "Edit", match: :first

    fill_in "Properties", with: @scheduled_tweet.properties
    fill_in "Text", with: @scheduled_tweet.text
    fill_in "Uid", with: @scheduled_tweet.uid
    click_on "Update Scheduled tweet"

    assert_text "Scheduled tweet was successfully updated"
    click_on "Back"
  end

  test "destroying a Scheduled tweet" do
    visit scheduled_tweets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Scheduled tweet was successfully destroyed"
  end
end

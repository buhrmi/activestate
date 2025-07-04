require "application_system_test_case"

class ActiveStateTest < ApplicationSystemTestCase

  test 'subscribing, updating, appending' do
    visit '/messages'
    assert_text 'old1old3'
    assert_text "123456"
    assert_text "henlo"
    assert_text "foundme"
    assert_text "Delete Me: deleteme"
    assert_text "deleteMe"
    assert_text "keepMe"
    click_on 'Make Message'
    assert_no_text "foundme"
    assert_no_text "henlo"
    assert_text "new name"
    assert_text "gotcha"
    assert_text 'new1old3new2'
    assert_text "Hello World"
    assert_text "123456 appended"
    assert_no_text "deleteme"
    assert_no_text "deleteMe"
    assert_text "keepMe"
    assert_text "goofy"
    assert_text "goofy24"
    

  end
end

# Copyright (C) The Arvados Authors. All rights reserved.
#
# SPDX-License-Identifier: AGPL-3.0

require 'integration_helper'

class TrashTest < ActionDispatch::IntegrationTest
  setup do
    need_javascript
  end

  test "trash page" do
    deleted = api_fixture('collections')['deleted_on_next_sweep']
    expired1 = api_fixture('collections')['unique_expired_collection']
    expired2 = api_fixture('collections')['unique_expired_collection2']

    # visit trash page
    visit page_with_token('active', "/trash")

    assert_text deleted['name']
    assert_text expired1['name']
    assert_no_text expired2['name']   # not readable by this user
    assert_no_text 'foo_file'         # not trash

    # Un-trash one item using selection dropdown
    within('tr', text: deleted['name']) do
      first('input').click
    end

    click_button 'Selection...'
    within('.selection-action-container') do
      click_link 'Un-trash selected items'
    end

    wait_for_ajax

    assert_text expired1['name']      # this should still be there
    assert_no_text deleted['name']    # this should no longer be here

    # Un-trash another item using the recycle button
    within('tr', text: expired1['name']) do
      first('.fa-recycle').click
    end

    wait_for_ajax

    assert_no_text expired1['name']

    # verify that the two un-trashed items are now shown in /collections page
    visit page_with_token('active', "/collections")
    assert_text deleted['uuid']
    assert_text expired1['uuid']
    assert_no_text expired2['uuid']
  end

  test "trash page with search" do
    deleted = api_fixture('collections')['deleted_on_next_sweep']
    expired = api_fixture('collections')['unique_expired_collection']

    visit page_with_token('active', "/trash")

    assert_text deleted['name']
    assert_text expired['name']

    page.find_field('Search trash').set 'expired'

    assert_text expired['name']
    assert_no_text deleted['name']

    click_button 'Selection...'
    within('.selection-action-container') do
      assert_selector 'li.disabled', text: 'Un-trash selected items'
    end

    first('input').click

    click_button 'Selection...'
    within('.selection-action-container') do
      assert_selector 'li', text: 'Un-trash selected items'
      assert_selector 'li.disabled', text: 'Un-trash selected items'
    end
  end
end

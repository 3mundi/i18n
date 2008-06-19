$:.unshift 'lib/i18n/lib'

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'active_support'
require 'action_pack'

require 'i18n'
require 'patch/date_helper'
require 'patch/translations'

class DateHelperDistanceOfTimeInWordsI18nTests < Test::Unit::TestCase
  include ActionView::Helpers::DateHelper
  attr_reader :request
  
  def setup
    @request = mock
    @from = Time.mktime(2004, 6, 6, 21, 45, 0)
  end
  
  # distance_of_time_in_words

  def test_distance_of_time_in_words_given_a_locale_it_does_not_check_request_for_locale
    request.expects(:locale).never
    distance_of_time_in_words @from, @from + 1.second, false, :locale => 'en-US'
  end
  
  def test_distance_of_time_in_words_given_no_locale_it_checks_request_for_locale
    request.expects(:locale).returns 'en-US'
    distance_of_time_in_words @from, @from + 1.second
  end
  
  def test_distance_of_time_in_words_calls_i18n
    { # with include_seconds
      [2.seconds,  true]  => [:'less_than_x_seconds', 5],   
      [9.seconds,  true]  => [:'less_than_x_seconds', 10],  
      [19.seconds, true]  => [:'less_than_x_seconds', 20],  
      [30.seconds, true]  => [:'half_a_minute',       nil], 
      [59.seconds, true]  => [:'less_than_x_minutes', 1], 
      [60.seconds, true]  => [:'x_minutes',           1], 
      
      # without include_seconds
      [29.seconds, false] => [:'less_than_x_minutes', 1],
      [60.seconds, false] => [:'x_minutes',           1],
      [44.minutes, false] => [:'x_minutes',           44],
      [61.minutes, false] => [:'about_x_hours',       1],
      [24.hours,   false] => [:'x_days',              1],
      [30.days,    false] => [:'about_x_months',      1],
      [60.days,    false] => [:'x_months',            2],
      [1.year,     false] => [:'about_x_years',       1],
      [3.years,    false] => [:'over_x_years',        3]
      
      }.each do |passed, expected|
      assert_distance_of_time_in_words_translates_key passed, expected
    end
  end
  
  def assert_distance_of_time_in_words_translates_key(passed, expected)
    diff, include_seconds = *passed
    key, count = *expected    
    to = @from + diff

    options = {:locale => 'en-US', :scope => :'datetime.distance_in_words'}
    options[:count] = count if count
    
    I18n.expects(:t).with(key, options)
    distance_of_time_in_words(@from, to, include_seconds, :locale => 'en-US')
  end
end
  
class DateHelperSelectTagsI18nTests < Test::Unit::TestCase
  include ActionView::Helpers::DateHelper
  attr_reader :request
  
  def setup
    @request = mock
    I18n.stubs(:translate).with(:'date.month_names', 'en-US').returns Date::MONTHNAMES
  end
  
  # select_month
  
  def test_select_month_given_use_month_names_option_does_not_translate_monthnames
    I18n.expects(:translate).never
    select_month(8, :locale => 'en-US', :use_month_names => Date::MONTHNAMES)
  end
  
  def test_select_month_translates_monthnames
    I18n.expects(:translate).with(:'date.month_names', 'en-US').returns Date::MONTHNAMES
    select_month(8, :locale => 'en-US')
  end
  
  def test_select_month_given_use_short_month_option_translates_abbr_monthnames
    I18n.expects(:translate).with(:'date.abbr_month_names', 'en-US').returns Date::ABBR_MONTHNAMES
    select_month(8, :locale => 'en-US', :use_short_month => true)
  end
  
  # date_or_time_select
  
  def test_date_or_time_select_given_an_order_options_does_not_translate_order
    I18n.expects(:translate).never
    datetime_select('post', 'updated_at', :order => [:year, :month, :day], :locale => 'en-US')
  end
  
  def test_date_or_time_select_given_no_order_options_translates_order
    I18n.expects(:translate).with(:'date.order', 'en-US').returns [:year, :month, :day]
    datetime_select('post', 'updated_at', :locale => 'en-US')
  end
end
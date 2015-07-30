require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = Contact.new
  end
end

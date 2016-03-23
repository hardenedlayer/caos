require 'test_helper'
require 'pp'
require 'softlayer/object_storage'
require File.join(File.dirname(__FILE__), 'creds.rb')

class StorageObjectTest < ActiveSupport::TestCase
  def test_the_truth
    conn = SoftLayer::ObjectStorage::Connection.new(CREDS)
    r = conn.search(q: 'Can Meeting 2016', field: 'meta.event')
    assert r[:count] > 0

    i = r[:items][0]
    cont = conn.container(i["container"])
    obj = cont.object(i["name"])

    #puts r.to_json
    #puts i.to_json
    #puts obj.to_json
    puts 'temp url for object ----------------------'
    puts obj.temp_url(30)
    puts JSON.pretty_generate(obj.object_metadata)
    assert true
  end
end

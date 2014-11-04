require 'json'
require 'jschematic'
require 'time'
require 'httparty'

require 'har/error'
require 'har/version'
require 'har/serializable'
require 'har/schema_type'
require 'har/page'
require 'har/request'
require 'har/response'
require 'har/archive'
require 'har/stats'
require 'har/entry'
require 'har/entry_collection'
require 'har/referer'
require 'har/viewer'
require 'har/domain_collection'
require 'har/extensions/jschematic/attributes/format'


module Enumerable
  def group_by
    assoc = {}

    each do |element|
      key = yield(element)

      if assoc.has_key?(key)
        assoc[key] << element
      else
        assoc[key] = [element]
      end
    end

    assoc
  end unless [].respond_to?(:group_by)
end

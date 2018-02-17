require "deltaconveyor/version"
require "deltaconveyor/row"
require "deltaconveyor/option"
require "deltaconveyor/container"

module Deltaconveyor
  class InvalidRowError < StandardError; end
  class RemovingOriginalError < StandardError; end
  def self.import(data, option, container, force_remove: false)
    originals = container.originals

    passes_container = option.row_class.method(:from_json).parameters.size == 2
    rows = data.map do |d|
      passes_container ? option.row_class.from_json(d, container) : option.row_class.from_json(d)
    end

    invalids = rows.reject(&:valid?)
    if invalids.size > 0
      option.logger.error 'Error: Some data has errors.'
      invalids.each do |invalid|
        option.logger.error invalid.errors.messages.to_s
      end
      raise InvalidRowError, 'Not Imported.'
    end

    option_keys = Array(option.key)
    original_hash = index_by_keys(originals, option_keys)
    new_hash = index_by_keys(rows, option_keys)

    original_keys = original_hash.keys
    new_keys = new_hash.keys

    intersection_keys = original_keys & new_keys
    remove_keys = original_keys - intersection_keys
    adding_keys = new_keys - intersection_keys

    if remove_keys.size > 0 && !force_remove
      option.logger.error 'Error: Some data is facing to remove but `force_remove` flag is false'
      option.logger.error 'so import is stopped.'
      option.logger.error 'Removing keys:'
      option.logger.error remove_keys
      raise RemovingOriginalError, 'Not Imported.'
    end

    remove_keys.each do |key|
      original_data = original_hash[key]
      raise 'Bug.' unless original_data
      option.logger.info "Remove #{key}"
      # TODO: rethink
      original_data.destroy!
    end
    option.logger.info 'Removing Phase is finished.'

    intersection_keys.each do |key|
      original_data = original_hash[key]
      new_data = new_hash[key]
      raise 'Bug.' unless original_data && new_data

      new_data.update!(original_data)
    end
    option.logger.info 'Updating Phase is finished.'

    adding_keys.each do |key|
      new_data = new_hash[key]
      raise 'Bug.' unless new_data

      option.logger.info "Insert #{key}"
      new_data.save!
    end
    option.logger.info 'Adding Phase is finished.'
    nil
  end

  def self.index_by_keys(arr, keys)
    hash = {}
    arr.each do |elem|
      pk = keys.map { |key| elem.send(key) }
      unless hash[pk].nil?
        option.logger.error "Error: not unique key #{pk}"
        raise 'Not Imported.'
      end
      hash[pk] = elem
    end
    hash
  end
end

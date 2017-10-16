require "deltaconveyor/version"
require "deltaconveyor/row"
require "deltaconveyor/config"
require "deltaconveyor/container"

module Deltaconveyor
  def self.import(data, container, force_remove: false)
    originals = container.originals
    config = container.config

    rows = data.map { |d| config.row_class.from_json(d, container) }
    invalids = rows.reject(&:valid?)
    if invalids.size > 0
      config.error_logger 'Error: Some data has errors.'
      invalids.each do |invalid|
        config.error_logger invalid.errors.messages.to_s
      end
      raise 'Not Imported.'
    end

    original_hash = originals.index_by { |d| config.original_key(d) }
    new_hash = rows.index_by(&:key)

    original_keys = original_hash.keys
    new_keys = new_hash.keys

    intersection_keys = original_keys & new_keys
    remove_keys = original_keys - intersection_keys
    adding_keys = new_keys - intersection_keys

    if remove_keys.size > 0 && !force_remove
      config.error_logger 'Error: Some data is facing to remove but `force_remove` flag is false'
      config.error_logger 'so import is stopped.'
      config.error_logger 'Removing keys:'
      config.error_logger remove_keys
      raise 'Not Imported.'
    end

    remove_keys.each do |key|
      original_data = original_hash[key]
      raise 'Bug.' unless original_data
      config.info_logger "Remove #{key}"
      original_data.destroy!
    end
    config.info_logger 'Removing Phase is finished.'

    intersection_keys.each do |key|
      original_data = original_hash[key]
      new_data = new_hash[key]
      raise 'Bug.' unless original_data && new_data

      config.row_class.update!(original_data, new_data, container)
    end
    config.info_logger 'Updating Phase is finished.'

    adding_keys.each do |key|
      new_data = new_hash[key]
      raise 'Bug.' unless new_data

      config.info_logger "Insert #{key}"
      new_data.save!(container)
    end
    config.info_logger 'Adding Phase is finished.'
    nil
  end
end

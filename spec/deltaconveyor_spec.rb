require "spec_helper"

RSpec.describe Deltaconveyor do
  it "has a version number" do
    expect(Deltaconveyor::VERSION).not_to be nil
  end

  # This method code is really bad so it cannot be well-tested.
  # want to refactor and write better tests later.
  describe '.import' do
    class Row < Deltaconveyor::Row
      attr_accessor :a, :b, :c
      def self.from_json(json)
        row = Row.new
        row.a = json['a']
        row.b = json['b']
        row.c = json['c']
        row
      end

      def valid?
        true
      end
    end

    class Original
      attr_accessor :a, :b, :c
      def initialize(a, b, c)
        self.a = a
        self.b = b
        self.c = c
      end
    end

    let(:row_class) { Row }
    let(:option) { Deltaconveyor::Option.new(row_class: row_class, key: key) }
    let(:container) { Deltaconveyor::Container.new(originals: originals) }
    let(:json) do
      [
        { 'a' => 1, 'b' => 2, 'c' => 1 },
        { 'a' => 2, 'b' => 2, 'c' => 1 },
        { 'a' => 3, 'b' => 4, 'c' => 1 },
      ]
    end

    context 'single key' do
      let(:key) { 'a' }
      let(:original1) { Original.new(1, 2, 1) }
      let(:original2) { Original.new(2, 3, 2) }
      let(:original3) { Original.new(4, 4, 1) }

      let(:originals) { [original1, original2, original3] }

      it 'removing error' do
        expect { Deltaconveyor.import(json, option, container, force_remove: false) }.to raise_error(Deltaconveyor::RemovingOriginalError)
      end

      it 'normal' do
        # really bad.
        class Row
          @@save_count = 0
          @@update_count = 0
          def save!
            @@save_count += 1
          end

          def update!(original)
            @@update_count += 1
          end
          def self.save_count; @@save_count; end
          def self.update_count; @@update_count; end
        end
        class Original
          @@remove_count = 0
          def destroy!
            @@remove_count += 1
          end
          def self.remove_count; @@remove_count; end
        end
        Deltaconveyor.import(json, option, container, force_remove: true)
        is_asserted_by { Row.update_count == 2 }
        is_asserted_by { Row.save_count == 1 }
        is_asserted_by { Original.remove_count == 1 }
      end
    end
  end
end

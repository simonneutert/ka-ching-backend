# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :bookings do
      uuid :id, primary_key: true

      String :action, index: true, null: false
      Integer :amount_cents, null: false
      DateTime :realized_at, index: true
      column :context, :jsonb, null: false

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP, index: true

      validate do
        includes %w[withdraw deposit], :action
      end
    end
  end
end

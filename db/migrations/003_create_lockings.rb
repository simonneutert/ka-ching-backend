# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :lockings do
      primary_key :id

      Integer :saldo_cents_calculated, null: false
      Integer :amount_cents_saldo_user_counted, null: false
      TrueClass :active, default: true, index: true, null: false
      DateTime :realized, index: true
      column :bookings_json, :jsonb, null: false
      column :context, :jsonb, null: false

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP, index: true

      validate do
        operator :>=, 0, :saldo_cents_calculated
        operator :>=, 0, :amount_cents_saldo_user_counted
      end
    end
  end
end

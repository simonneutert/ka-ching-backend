# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :tenants do
      uuid :id, primary_key: true

      String :tenant_db_id, unique: true, index: true, null: false
      TrueClass :active, index: true, null: false
      String :current_state, index: true, null: false
      String :next_state, index: true
      column :context, :jsonb, default: {}.to_json, null: false

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP, index: true
    end
  end

  down do
    drop_table :tenants
  end
end

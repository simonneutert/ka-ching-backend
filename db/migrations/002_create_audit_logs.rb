# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :audit_logs do
      primary_key :id

      String :table_referenced, index: true, default: 'system'
      column :environment_snapshot, :jsonb, null: false
      column :log_entry, :jsonb, null: false

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP, index: true
    end
  end

  down do
    drop_table :audit_logs
  end
end

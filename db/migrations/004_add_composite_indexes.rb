# frozen_string_literal: true

Sequel.migration do
  up do
    # Bookings table composite indexes for common query patterns

    # For queries filtering by action and realized_at together
    # Used in: saldo calculations, booking range queries in locker
    add_index :bookings, %i[action realized_at], name: :idx_bookings_action_realized_at # rubocop:disable Sequel/ConcurrentIndex

    # For queries filtering by realized_at ranges (most common pattern)
    # Improves queries that filter by realized_at > X and realized_at <= Y
    # Already has single index on realized_at, but this composite covers action filters too

    # For queries ordering by realized_at with action filter
    # Used in: booking range queries that need sorting
    add_index :bookings, %i[realized_at action], name: :idx_bookings_realized_at_action # rubocop:disable Sequel/ConcurrentIndex

    # Lockings table composite indexes

    # For queries filtering by active status and realized_at together
    # Used in: active_in_date_range_order_realized_at_desc, latest_active queries
    add_index :lockings, %i[active realized_at], name: :idx_lockings_active_realized_at # rubocop:disable Sequel/ConcurrentIndex

    # For queries filtering by realized_at ranges with active status
    # Optimizes queries that check active lockings in date ranges
    add_index :lockings, %i[realized_at active], name: :idx_lockings_realized_at_active # rubocop:disable Sequel/ConcurrentIndex

    # Partial index for active lockings only (most common case)
    # Since most queries filter for active: true, this speeds up those queries significantly
    add_index :lockings, :realized_at, name: :idx_lockings_active_realized_at_partial, # rubocop:disable Sequel/ConcurrentIndex
                                       where: { active: true }
  end

  down do
    drop_index :bookings, name: :idx_bookings_action_realized_at # rubocop:disable Sequel/ConcurrentIndex
    drop_index :bookings, name: :idx_bookings_realized_at_action # rubocop:disable Sequel/ConcurrentIndex
    drop_index :lockings, name: :idx_lockings_active_realized_at # rubocop:disable Sequel/ConcurrentIndex
    drop_index :lockings, name: :idx_lockings_realized_at_active # rubocop:disable Sequel/ConcurrentIndex
    drop_index :lockings, name: :idx_lockings_active_realized_at_partial # rubocop:disable Sequel/ConcurrentIndex
  end
end

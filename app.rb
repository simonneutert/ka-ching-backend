# frozen_string_literal: true

require 'logger'
require 'oj'
require 'alba'
require 'pry' unless ENV['RACK_ENV'] == 'production'
require 'roda'
require 'rack/deflater'
require 'securerandom'

require_relative 'db'

Alba.backend = :oj

def rack_env_production?
  ENV.fetch('RACK_ENV', nil) == 'production'
end

def parse_on_off(str)
  case str.downcase
  when 'false', 'off', 'no', '0', 'nil', 'null', 'none', 'disabled', 'disable', 'inactive', 'deactivated'
    false
  when 'true', 'on', 'yes', '1', 'enabled', 'enable', 'active', 'activated'
    true
  else
    raise ArgumentError, "Invalid value for KACHING_RESET_PROTECTION: #{str}"
  end
end

def reset_protection_enabled?
  val = ENV.fetch('KACHING_RESET_PROTECTION', false)
  return false if val.nil?

  val_s = val.to_s
  return false if val_s.empty?

  parse_on_off(val_s)
end

def rich_error_return(error, error_key)
  rich_return = error.send(error_key)
  return { status: error.class, message: error.to_s } unless rich_return

  { status: error.class,
    message: error.to_s,
    error_object: error.send(error_key) }
end

def get_lockings_query(conn, date_range, active, inactive)
  if active
    query_lockings(conn).active_in_date_range_order_realized_at_desc(date_range)
  elsif inactive
    query_lockings(conn).inactive_in_date_range_order_realized_at_desc(date_range)
  else
    query_lockings(conn).in_date_range_order_realized_at_desc(date_range)
  end
end

class App < Roda
  RESET_PROTECTION_ENABLED = reset_protection_enabled?

  plugin :json, configure: ->(c) { c.engine = :alba }
  plugin :json_parser
  plugin :all_verbs
  plugin :halt
  plugin :public

  use Rack::Deflater

  def query_audit_logs(conn)
    Api::V1::Repository::AuditLogs.new(conn)
  end

  def query_lockings(conn)
    Api::V1::Repository::Lockings.new(conn)
  end

  def query_bookings(conn)
    Api::V1::Repository::Bookings.new(conn)
  end

  def query_saldos(conn)
    Api::V1::Repository::Saldo.new(conn)
  end

  def result_paginated(query_to_paginate, page, per_page)
    q = query_to_paginate.paginate(page, per_page)
    {
      current_page: q.current_page,
      current_page_record_count: q.current_page_record_count,
      current_page_record_range: q.current_page_record_range,
      first_page: q.first_page?,
      last_page: q.last_page?,
      next_page: q.next_page,
      page_count: q.page_count,
      page_range: q.page_range,
      page_size: q.page_size,
      pagination_record_count: q.pagination_record_count,
      prev_page: q.prev_page,
      items: q.all
    }
  end

  route do |r|
    default_status = { api: 'V1',
                       health: :success,
                       status: :ok }

    r.root do
      default_status
    end

    r.public

    r.on 'ka-ching' do
      r.is do
        default_status
      end

      r.on 'api' do
        r.on 'v1' do
          r.on 'admin' do
            r.on String do |tenant_account_id|
              r.get do
                database = "#{DB::DATABASE_TENANT_DATABASE_NAMESPACE}#{tenant_account_id}"
                res = DB::DATABASE_SHARED_CONN[:tenants].where(tenant_db_id: database).first
                return res if res

                response.status = 204
                next
              end

              r.post 'reset' do
                next if RESET_PROTECTION_ENABLED

                tenant_db_connector = Db::SequelTenantDbConnector.new(
                  tenant_id: tenant_account_id,
                  auto_init: false
                )
                resetter = Api::V1::Repository::DbPreparator.new(tenant_account_id)
                resetter.reset!

                { api: 'V1',
                  health: :success,
                  db: tenant_db_connector.connect_close(&:tables) }
              end
            end

            r.post do
              tenant_account_id = r.params['tenant_account_id']
              raise ArgumentError if tenant_account_id.nil?

              tenant_db_connector = Db::SequelTenantDbConnector.new(tenant_id: tenant_account_id, auto_init: true)
              tenant_db_connector.find_or_create!
              tables = tenant_db_connector.connect_close(&:tables)
              { api: 'V1',
                health: :success,
                db: tables }
            end

            r.delete do
              tenant_account_id = r.params['tenant_account_id']
              raise ArgumentError if tenant_account_id.nil?

              database = "#{DB::DATABASE_TENANT_DATABASE_NAMESPACE}#{tenant_account_id}"
              DB::DATABASE_TENANT_BLANK_CONN.run("DROP DATABASE #{database} WITH (FORCE);")
              # update the shared tenant table, so we know the tenant is dropped
              DB::DATABASE_SHARED_CONN[:tenants].where(tenant_db_id: database)
                                                .update(active: false, updated_at: Time.now, current_state: 'dropped')

              { api: 'V1',
                health: :success,
                result: :dropped }
            end
          end

          r.on 'tenants' do
            r.get 'all' do
              page = r.params['page']
              page = 1 if page.nil?
              per_page = r.params['per_page']
              per_page = 1000 if per_page.nil?
              result_paginated(DB::DATABASE_SHARED_CONN[:tenants], page.to_i, per_page.to_i)
            end

            r.get 'active' do
              page = r.params['page']
              page = 1 if page.nil?
              per_page = r.params['per_page']
              per_page = 1000 if per_page.nil?
              q = DB::DATABASE_SHARED_CONN[:tenants].where(active: true)
              result_paginated(q, page.to_i, per_page.to_i)
            end

            r.get 'inactive' do
              page = r.params['page']
              page = 1 if page.nil?
              per_page = r.params['per_page']
              per_page = 1000 if per_page.nil?
              q = DB::DATABASE_SHARED_CONN[:tenants].where(active: [false, nil])
              result_paginated(q, page.to_i, per_page.to_i)
            end
          end

          r.on String do |tenant_account_id|
            r.is do
              tenant_db_connector = Db::SequelTenantDbConnector.new(tenant_id: tenant_account_id)

              { api: 'V1',
                health: :success,
                db: tenant_db_connector.connect_close(&:tables) }
            end

            # SETUP the database connection for a specific's tenant interaction

            tenant_db_connector = Db::SequelTenantDbConnector.new(
              tenant_id: tenant_account_id,
              auto_init: false
            )

            tenant_db_connector.connect_close do |conn|
              # SETUP the database connection for a specific's tenant interaction
              # and load the extensions we need
              conn.extension(:pg_extended_date_support,
                             :constraint_validations,
                             :pagination,
                             :pg_json)

              r.on 'saldo' do
                { saldo: query_saldos(conn).sum_up }
              end

              r.on 'bookings' do
                r.on 'unlocked' do
                  latest_active_locking = query_lockings(conn).latest_active[:realized_at]
                  bookings = query_bookings(conn).active(latest_active_locking)

                  { bookings: bookings }
                end

                r.post do
                  booker = Api::V1::Booking::Booker.new(conn, r.params)
                  booker.book!
                rescue ArgumentError => e
                  response.status = 400
                  { status: e.class, message: e.to_s }
                rescue Api::V1::Booking::BookerError => e
                  response.status = 400
                  rich_error_return(e, :error_obj)
                end

                r.delete do
                  uuid = r.params['id']
                  raise Api::V1::Booking::BookerError, 'Booking ID is missing!' unless uuid

                  Api::V1::Booking::Deleter.new(conn, uuid).delete!
                rescue Api::V1::Booking::BookerError => e
                  response.status = 400
                  rich_error_return(e, :error_obj)
                end
              end

              r.on 'lockings' do
                r.post do
                  locker = Api::V1::Locking::Locker.new(conn, r.params)
                  newest_locking_id = locker.lock!
                  newest_locking = query_lockings(conn).find_by(id: newest_locking_id)
                rescue Api::V1::Locking::LockingError, Api::V1::Locking::NegativeSaldoError => e
                  response.status = 403
                  rich_error_return(e, :error_obj)
                rescue Sequel::CheckConstraintViolation => e
                  response.status = 403
                  message = e.to_s
                  message = 'Saldo cannot be negative!' if lock_params.amount_cents_saldo_user_counted.negative?
                  { error: e.class, message: message }
                else
                  { status: !newest_locking_id.nil?,
                    saldo: newest_locking[:amount_cents_saldo_user_counted],
                    diff: newest_locking[:amount_cents_saldo_user_counted] - newest_locking[:saldo_cents_calculated],
                    record: newest_locking,
                    context: newest_locking[:context] }
                end

                r.delete do
                  deactivator = Api::V1::Locking::Deactivator.new(conn)
                  deactivator.open_last_locking!
                rescue Api::V1::Locking::DeactivatorError => e
                  response.status = 403
                  rich_error_return(e, :error_obj)
                end

                r.get do
                  year = Integer(r.params['year']) if r.params['year']
                  active = r.params['active'] && parse_on_off(r.params['active'])
                  inactive = r.params['inactive'] && parse_on_off(r.params['inactive'])
                  page = r.params['page'] ||= 1
                  per_page = r.params['per_page'] ||= 100

                  if year
                    date_range = Date.new(year, 1, 1)..Date.new(year, 12, 31)
                    q = get_lockings_query(conn, date_range, active, inactive)
                    result_paginated(q, Integer(page), Integer(per_page))
                  else
                    query_lockings(conn).all(page: page, per_page: per_page, order: :realized_at)
                  end
                end
              end

              r.on 'auditlogs' do
                r.get do
                  year = Integer(r.params['year']) if r.params['year']
                  raise ArgumentError, 'Missing year parameter!' unless year&.positive?

                  month = Integer(r.params['month']) if r.params['month']
                  day = Integer(r.params['day']) if r.params['day']

                  if year && month && day
                    { audit_logs: query_audit_logs(conn).for_day(year, month, day) }
                  elsif year && month
                    { audit_logs: query_audit_logs(conn).for_month(year, month) }
                  elsif year
                    { audit_logs: query_audit_logs(conn).for_year(year) }
                  end
                end
              end
            end
          end
          default_status
        end
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    module Helper
      module DatabaseConnection
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

        private

        def db(tenant_db_connector, table)
          result = nil
          tenant_db_connector.connect_close do |connection|
            connection.extension(:pagination)
            conn = connection[table.to_sym]
            result = yield conn
          end
          result
        end
      end
    end
  end
end

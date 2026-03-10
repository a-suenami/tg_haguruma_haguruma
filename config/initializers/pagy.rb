# frozen_string_literal: true

require 'pagy/extras/overflow'

Pagy::DEFAULT[:items] = 20 # items per page
Pagy::DEFAULT[:overflow] = :last_page
# Series format: [start_pages, before_current, after_current, end_pages]
# This creates: 1 ... 6 [7] 8 ... 13
Pagy::DEFAULT[:size] = [1, 1, 1, 1]

# frozen_string_literal: true

# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
# ++

module WorkPackages
  module Exports
    module PDF
      module Report
        class ExportSettingsComponent < BaseExportSettingsComponent
          DESCRIPTION_CF = { id: "description", name: WorkPackage.human_attribute_name("description") }.freeze

          def available_long_text_fields
            [DESCRIPTION_CF] + WorkPackageCustomField.where(field_format: "text")
                                                     .map { |cf| { id: cf.id, name: cf.name } }
          end

          def selected_long_text_fields
            available_long_text_fields
          end

          def protected_long_text_fields
            []
          end
        end
      end
    end
  end
end

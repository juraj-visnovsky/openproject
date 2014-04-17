#-- copyright
# OpenProject Global Roles Plugin
#
# Copyright (C) 2010 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

require File.dirname(__FILE__) + '/../spec_helper'

describe PrincipalRolesController do
  before(:each) do
    @controller.stub!(:require_admin).and_return(true)
    @controller.stub!(:check_if_login_required).and_return(true)
    @controller.stub!(:set_localization).and_return(true)

    @principal_role = mock_model PrincipalRole

    if privacy_plugin_loaded?
      @principal_role.stub!(:privacy_unnecessary=)
      @principal_role.stub!(:valid?).and_return(true)
      @principal_role.stub!(:privacy_statement_necessary?).and_return(false)
    end

    @principal_role.stub!(:id).and_return(23)
    PrincipalRole.stub!(:find).and_return @principal_role
    disable_flash_sweep
    disable_log_requesting_user
  end

  describe :post do
    before :each do
      @params = {"principal_role"=>{"principal_id"=>"3", "role_ids"=>["7"]}}
    end

    unless privacy_plugin_loaded? #tests than are defined in privacy_plugin

      describe :create do
        before :each do

        end

        describe "SUCCESS" do
          before :each do
            @global_role = mock_model(GlobalRole)
            @global_role.stub!(:id).and_return(42)
            ##
            # Note this test uses doubles which may break depending on the loaded plugins.
            # Specifically extra stubs have been added for these tests to work with the
            # openproject-impermanent_memberships plugin which would be otherwise unexpected.
            # Those stubs are marked with the comment "only necessary with impermanent-memberships".
            #
            # If this problem occurs again with another plugin (or the same, really) this should be fixed for good
            # by using FactoryGirl to create actual model instances.
            # I'm only patching this up right now because I don't want to spend any more time on it and
            # the added methods are orthogonal to the test, also additional, unused stubs won't break things
            # as opposed to missing ones.
            #
            # And yet: @TODO Don't use doubles but FactoryGirl.
            @global_role.stub!(:permanent?).and_return(false) # only necessary with impermanent-memberships
            Role.stub!(:find).and_return([@global_role])
            PrincipalRole.stub!(:new).and_return(@principal_role)
            @user = mock_model User
            @user.stub!(:valid?).and_return(true)
            @user.stub!(:logged?).and_return(true)
            @user.stub!(:global_roles).and_return([]) # only necessary with impermanent-memberships
            Principal.stub!(:find).and_return(@user)
            @principal_role.stub!(:role=)
            @principal_role.stub!(:role).and_return(@global_role)
            @principal_role.stub!(:principal_id=)
            @principal_role.stub!(:save)
            @principal_role.stub!(:role_id).and_return(@global_role.id)
            @principal_role.stub!(:valid?).and_return(true)
          end

          describe "js" do
            before :each do
              response_should_render :replace,
                                     "available_principal_roles",
                                     :partial => "users/available_global_roles",
                                     :locals => {:global_roles => anything(),
                                                 :user => anything()}
              response_should_render :insert_html,
                                     :top, 'table_principal_roles_body',
                                     :partial => "principal_roles/show_table_row",
                                     :locals => {:principal_role => anything()}

              #post :create, { "format" => "js", "principal_role"=>{"principal_id"=>"3", "role_ids"=>["7"]}}
              xhr :post, :create, @params
            end

            it { response.should be_success }
          end
        end
      end
    end
  end

  describe :put do
    before :each do
      @params = {"principal_role"=>{"id"=>"6", "role_id" => "5"}}
    end

    describe :update do
      before(:each) do
        @principal_role.stub!(:update_attributes)
      end

      describe "SUCCESS" do
        describe "js" do
          before :each do
            @principal_role.stub!(:valid?).and_return(true)

            response_should_render :replace,
                                  "principal_role-#{@principal_role.id}",
                                  :partial => "principal_roles/show_table_row",
                                  :locals => {:principal_role => anything()}

            xhr :put, :update, @params
          end

          it {response.should be_success}
        end
      end

      describe "FAILURE" do
        describe "js" do
          before :each do
            @principal_role.stub!(:valid?).and_return(false)
            response_should_render :insert_html,
                                   :top,
                                   "tab-content-global_roles",
                                   :partial => 'errors'

            xhr :put, :update, @params
          end

          it {response.should be_success}
        end
      end
    end
  end

  describe :delete do
    before :each do
      @principal_role.stub!(:principal_id).and_return(1)
      @user = mock_model User
      @user.stub!(:logged?).and_return(true)
      @user.stub!(:global_roles).and_return([]) # only necessary with impermanent-memberships
      Principal.stub(:find).and_return(@user)
      @principal_role.stub!(:destroy)
      @principal_role.stub!(:role).and_return(Struct.new(:id, :permanent?).new(42, false)) # only necessary with impermanent-memberships
      @params = {"id" => "1"}
    end

    describe :destroy do
      describe "SUCCESS" do
        before :each do
          response_should_render :remove, "principal_role-#{@principal_role.id}"
          response_should_render :replace,
                                 "available_principal_roles",
                                 :partial => "users/available_global_roles",
                                 :locals => {:global_roles => anything(),
                                             :user => anything()}
        end

        describe "js" do
          before :each do
            xhr :delete, :destroy, @params
          end

          it { response.should be_success }
        end
      end
    end
  end
end

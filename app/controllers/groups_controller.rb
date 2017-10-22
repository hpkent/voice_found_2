class GroupsController < ApplicationController

  #clients_groups
  def all_clients_in_group
    @group = Group.find(params[:id])
    @group_id = @group.id
    @group_name = @group.name
    @clients_groups = StudentsGroup.new
    @look_up_group = Group.where(name:@group_name)
    @look_up_group_id = @look_up_group.first.id
    @clients_in_groups = Student.select('clients.id, clients.first_name, clients.last_name, clients_groups.id AS clients_groups_id, groups.name AS group_name, category_types.name AS category_name').joins('
    INNER JOIN clients_groups ON clients_groups.client_id = clients.id
    INNER JOIN groups ON clients_groups.group_id = groups.id
    LEFT OUTER JOIN category_types ON category_types.id = clients.category_type_id'
    ).where("
    groups.id =?", @look_up_group_id).order(:first_name)
    @clients = Student.active_client.order(:category_type_id)
  end

  def update_clients_in_group
    @clients_group = StudentsGroup.where(group_id:params[:clients_group][:group_id],client_id:params[:clients_group][:client_id]).first_or_initialize
    respond_to do |format|
      if (@clients_group.update(clients_group_params))
      @group_id = @clients_group.group_id
        format.html { redirect_to("/groups/#{@group_id}/all_clients_in_group") }
        format.json
        format.js
      else
        format.html { redirect_to("/groups/#{@group_id}/all_clients_in_group") }
      end
    end
  end

  def delete_clients_groups
    clients_groups = StudentsGroup.find(params[:clients_groups_id])
    @group_id = clients_groups.group_id
    clients_groups.destroy
    respond_to do |format|
      format.html { redirect_to "/groups/#{@group_id}/all_clients_in_group"}
      format.json
      format.js
    end
  end

  #groups
  def manage_groups
     @groups = Group.all.order(:name)
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.where(id:params[:id]).first_or_initialize
    if @group.update(group_params)
      redirect_to groups_manage_groups_path
    else
      render 'edit'
    end
  end

  def delete_group
    group = Group.find(params[:id])
    group.destroy
    redirect_to '/groups/manage_groups'
  end

  private
    def group_params
      params.require(:group).permit(:name, :description)
    end

    def clients_group_params
      params.require(:clients_group).permit(:group_id, :client_id)
    end
end







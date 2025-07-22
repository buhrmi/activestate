class MessagesController < ApplicationController

  before_action :set_user
  def index
  end

  def create
    UserChannel[@user].state('user').assign({id: @user.id, name: "new name"})
    UserChannel[@user].state('messages').push([params[:message]])
    UserChannel[@user].state('records').upsert([{id: 1, name: "new1"}, {id: 2, name: "new2"}])
    UserChannel[@user].state('deeply.nested').set({value: "gotcha"})
    UserChannel[@user].state('longString').append(" appended")
    UserChannel[@user].state('val').delete "deleteme"
    UserChannel[@user].state('delete.array').delete name: 'deleteMe'
    UserChannel[@user].state('numberkeys.23.person').set name: 'goofy3'
    UserChannel[@user].state('numberkeys', 24, 'person').set name: 'goofy24'
  end

  private
  def set_user
    @user = User.where(id: 1).first_or_create!(name: "henlo")
  end
end


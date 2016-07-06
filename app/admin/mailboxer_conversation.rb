# frozen_string_literal: true
ActiveAdmin.register Mailboxer::Conversation do
  menu parent: 'Mensajería'
  filter :created_at
  index do
    selectable_column
    actions
  end
end

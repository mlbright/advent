class AddNtfyTopicToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :ntfy_topic, :string
  end
end

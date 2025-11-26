class CreateRequestLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :request_logs do |t|
      t.string :ip_address, null: false
      t.string :path, null: false
      t.references :user, null: true, foreign_key: true
      t.string :user_agent
      t.string :request_method

      t.timestamps
    end

    add_index :request_logs, :ip_address
    add_index :request_logs, :created_at
  end
end

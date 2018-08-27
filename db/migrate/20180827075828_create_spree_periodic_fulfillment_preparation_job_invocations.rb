class CreateSpreePeriodicFulfillmentPreparationJobInvocations < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_periodic_fulfillment_preparation_job_invocations do |t|
      t.integer :state, null: false, default: 0
      t.integer :failed_count
      t.integer :reset_count
      t.integer :prepared_count
      t.float :running_time
      t.text :error_message

      t.timestamps
    end
  end
end

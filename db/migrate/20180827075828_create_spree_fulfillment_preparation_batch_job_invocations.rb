class CreateSpreeFulfillmentPreparationBatchJobInvocations < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_fulfillment_preparation_batch_job_invocations do |t|
      t.integer :state, null: false, default: 0, index: { name: 'index_spree_batch_fulfillment_prep_job_invocations_on_state' }
      t.integer :failed_count, default: 0
      t.integer :reset_count, default: 0
      t.integer :prepared_count, default: 0
      t.float :running_time
      t.text :error_message

      t.timestamps
    end
  end
end

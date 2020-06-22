class CreateCampaigns < ActiveRecord::Migration[4.2]
  def change
    create_table :campaigns do |t|

      t.timestamps null: false
    end
  end
end

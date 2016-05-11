class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|

      t.timestamps null: false
    end
  end
end

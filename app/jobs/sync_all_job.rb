class SyncAllJob < ApplicationJob
  def perform
    User.pluck(:id).each do |user_id|
      SyncUserJob.perform_later user_id
    end
  end
end

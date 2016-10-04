class SyncUserJob < ApplicationJob
  def perform user_id
    user = User.find user_id
    # Sync the bodystats
    bodystats_resp = user.rvs_connection.get("/users/#{user.rvs_id}/bodystats")
    if bodystats_resp.status == 200
      JSON.parse(bodystats_resp.body).each do |bodystat|
        unless user.synced_bodystat_ids.include?(bodystat['id'].to_s)
          SyncBodystatJob.perform_later user.id, bodystat
        end
      end
    else
      raise "Invalid rvs key of user #{user.inspect} | response: #{bodystats_resp}"
    end
  end
end

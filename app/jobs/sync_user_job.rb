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
      raise "Invalid rvs key of user #{user.id} with gamebus id #{user.gamebus_id} and rvs id #{user.rvs_id}"
    end

    # Sync the event scores
    events_resp = user.rvs_connection.get("/users/#{user.rvs_id}/events?include[]=attendees.scores.user&parsed_intervals=2000m")
    if events_resp.status == 200
      JSON.parse(events_resp.body).each do |event|
        next if user.synced_score_ids.include?(event['id'].to_s)
        event['attendees'].each do |attendee|
          next unless attendee['user_id'] == user.rvs_id
          next if attendee['scores'].blank?
          SyncScoreJob.perform_later user.id, event, attendee['scores'].first
        end
      end
    else
      raise "Invalid rvs key of user #{user.id} with gamebus id #{user.gamebus_id} and rvs id #{user.rvs_id}"
    end
  end
end

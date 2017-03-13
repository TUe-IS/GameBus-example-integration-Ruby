class SyncScoreJob < ApplicationJob
  def perform user_id, event, score
    user = User.find user_id
    activity_resp = user.gamebus_connection.post('/activity/new', {
      gameDescriptorId: 163845,
      # Date of the bodystat on 09:00 Z
      activityDate: DateTime.parse(event['start_time']).strftime('%FT%TZ'),
      properties: [
        {
          id: 119, # Sport type
          value: 'Rowing'
        },{
          id: 123, # Start time
          value: DateTime.parse(event['start_time']).strftime('%Q') # 1489395617153
        },{
          id: 124, # Distance
          value: 2000
        },{
          id: 125, # Total time in seconds
          value: score['split_time']*4/1000
        }
      ]
    }.to_json)
    if activity_resp.status == 200
      user.add_to_array :synced_score_ids, event['id']
    else
      raise "Invalid gamebus key of user #{user.id} with gamebus id #{user.gamebus_id} and rvs id #{user.rvs_id}"
    end
  end
end

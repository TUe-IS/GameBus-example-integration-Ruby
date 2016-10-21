class SyncBodystatJob < ApplicationJob
  def perform user_id, bodystat
    user = User.find user_id
    activity_resp = user.gamebus_connection.post('/activity/new', {
      gameDescriptorId: 65537,
      # Date of the bodystat on 09:00 Z
      activityDate: DateTime.parse(bodystat['date'] + 'T09:00').strftime('%FT%TZ'),
      properties: [
        {
          id: 67, # Weight (kg)
          value: bodystat['weight']
        },{
          id: 73, # Rest heart rate
          value: bodystat['heartrate']
        },{
          id: 162, # Hours slept
          value: bodystat['hours_of_sleep']
        },{
          id: 75, # Notes
          value: bodystat['comment_content']
        }
      ]
    }.to_json)
    if activity_resp.status == 200
      user.add_to_array :synced_bodystat_ids, bodystat['id']
    else
      raise "Invalid gamebus key of user #{user.inspect} | response: #{activity_resp.inspect}"
    end
  end
end

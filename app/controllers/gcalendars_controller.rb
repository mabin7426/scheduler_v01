class GcalendarsController < ApplicationController

  def busy
    @user = User.find(session[:user_id])
      client = Google::APIClient.new
      client.authorization.access_token = @user.token
      service = client.discovered_api('calendar', 'v3')
      @result = client.execute(
          api_method: service.freebusy.query,
          body: JSON.dump({
                timeMin: Time.now.beginning_of_day,
                timeMax: Time.now.end_of_day,
                timeZone: "America/Chicago",
                groupExpansionMax: 1,
                calendarExpansionMax: 1,
                items: [{id: "#{@user.calendar_id}"}]
                            }),
          headers:    {'Content-Type' => 'application/json'})
  end

  def events
      client = Google::APIClient.new
      client.authorization.access_token = @user.token
      service = client.discovered_api('calendar', 'v3')
      @resultlist = client.execute(
          api_method: service.events.list,
          parameters: {
            calendarId: "#{@user.calendar_id}",
            timeMin: "2013-05-28T00:00:00.000Z",
            timeMin: "2013-05-29T00:00:00.000Z"}
          )
  end
end

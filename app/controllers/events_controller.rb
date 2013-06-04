class EventsController < ApplicationController

# http_basic_authenticate_with :name => "kellogg", :password => "kellogg"
  require "open-uri"
  require "json"
  require 'active_support/core_ext'

  def see_tasks
    sort_direction = params["sortby"]
    if sort_direction == nil
      sort_direction = "asc"
    end
    @events = Event.order("priority #{sort_direction}").limit(100)
  end





  def add_tasks
    ##
    ## NOW NEED THE ACTUAL IF/THEN FORMULA TO ADD DURATION IN BETWEEN EXISTING EVENTS... ##
    ##
    sort_direction = params["sortby"]
    if sort_direction == nil
      sort_direction = "asc"
    end
    @events = Event.order("start #{sort_direction}").limit(100)
    @events_tasks = Event.order("priority #{sort_direction}").limit(100)


    # Find free time -- automatically create free time
    @work_start = Time.now.beginning_of_day
    @work_end = Time.now.end_of_day
    @events.each_cons(2) {|previous| current}
       free_time = Event.new
       free_time.title = "Free Time #{current}"
       if current == @events.first
          free_time.start = "@work_start"
          free_time.end = current.start
       end
       if current == @events.last
          free_time.start = current.end
          free_time.end = "@work_end"
       end
       if current != @events.first || @events.last
          free_time.start = previous.end
          free_time.end = current.start
       end
       free_time.notes = nil
       free_time.task = false
       free_time.user_id = User.find(session[:user_id])
       free_time.save



    # Slot in tasks by creating events, then subsequently destroying the free time event
    # Slot in task (block)
    #   if within free time
    #     create it
    #   else
    #     add what you can
    #     create rest of event in next available free time
    #   end
    # end

    ## What am I trying to do???
    # Analyze the existing events (from Google), and find the gaps between 8AM, the events, and 12AM
    # go through the list of tasks (ascended by priority, then due date if present), then make them into events

    # @events_tasks.each do |t|
    #   if t.task == true
    #    @event = Event.new
    #    @event.title = "TASK: #{t.title.upcase}"
    #    @event.start = "2013-05-31T08:00:00-05:00"
    #    end_time = @event.start.to_i + (t.duration * 60) #this will give me the number of minutes
    #    @event.end = Time.at(end_time)
    #    @event.notes = t.notes
    #    @event.task = false
    #    @event.user_id = User.find(session[:user_id])
    #    @event.save
    #   end
    # end

    redirect_to "/events"
  end





  def google_events
    @user = User.find(session[:user_id])
    client = Google::APIClient.new
    client.authorization.access_token = @user.token
    service = client.discovered_api('calendar', 'v3')
    @resultlist = client.execute(
        api_method: service.events.list,
        parameters: {
          calendarId: @user.calendar_id,
          maxResults: 3,
          timeZone: "America/Chicago",
          timeMin: "2013-05-31T00:00:00-0500",
          timeMax: "2013-06-01T00:00:00-0500"}
        )

    # Saves Google calendar events to database
    @resultlist.data["items"].each do |item|
      # if item["start"]["dateTime"] < "2006-05-29T12:30:00-05:00"
      # end
      ####
      # NEED TO FIGURE OUT HOW TO FILTER WHICH GOOGLE EVENTS TO SAVE (I.E. BEGINNING AND END_OF_DAY)
      ####
        @event = Event.new
        @event.title = item["summary"]
        @event.start = item["start"]["dateTime"]
        @event.end = item["end"]["dateTime"]
        @event.notes = nil
        @event.task = false
        @event.user_id = User.find(session[:user_id])
        @event.save
    end
    redirect_to "/events"
  end




  def index
    sort_direction = params["sortby"]
    if sort_direction == nil
      sort_direction = "asc"
    end
    @events = Event.order("start #{sort_direction}").limit(100)

    Time.zone = 'America/Chicago'
  end



  def delete_all_events
    sort_direction = params["sortby"]
    if sort_direction == nil
      sort_direction = "asc"
    end
    @events = Event.order("priority #{sort_direction}").limit(100)

    @events.each do |t|
      if t.task == false
         t.destroy
      end
    end
    redirect_to "/events"
  end





  def delete_all_tasks
    sort_direction = params["sortby"]
    if sort_direction == nil
      sort_direction = "asc"
    end
    @events = Event.order("priority #{sort_direction}").limit(100)

    @events.each do |t|
      if t.task == true
         t.destroy
      end
    end
    redirect_to "/see_tasks"
  end





  def new
  end

  def create
    @event = Event.new
    @event.title = params[:title]
    @event.priority = params[:priority]
    @event.due = params[:due]
    @event.duration = params[:duration]
    @event.notes = params[:notes]
    @event.task = true
    @event.start = DateTime.now.in_time_zone(Time.zone)
    @event.end = DateTime.now.in_time_zone(Time.zone)
    @event.user_id = User.find(session[:user_id])
    @event.save
    redirect_to "/events"
  end

  def show
    @event = Event.find_by_id(params[:id])
    @user = User.find(session[:user_id])
  end

  def edit
    @event = Event.find_by_id(params[:id])
  end

  def update
    @event = Event.find_by_id(params[:id])
    @event.title = params[:title]
    @event.priority = params[:priority]
    @event.due = params[:due]
    @event.notes = params[:notes]
    @event.save
    redirect_to "/events"
  end

  def destroy
    @event = Event.find_by_id(params[:id])
    @event.destroy
    redirect_to "/events"
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

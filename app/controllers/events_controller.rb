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

    # Testing if @resultlist is returning any value.
    if Event.find_by_task(false) == nil
    @user = User.find(session[:user_id])
    client = Google::APIClient.new
    client.authorization.access_token = @user.token
    service = client.discovered_api('calendar', 'v3')
    @resultlist = client.execute(
        api_method: service.events.list,
        parameters: {
          calendarId: @user.calendar_id,
          timeZone: "America/Chicago",
          orderBy: "startTime",
          singleEvents: true,
          timeMin: "2013-06-01T00:00:00-0500"}
        )
    end
  end



  def google_events
    if Event.find_by_task(false) == nil
        @user = User.find(session[:user_id])
        client = Google::APIClient.new
        client.authorization.access_token = @user.token
        service = client.discovered_api('calendar', 'v3')
        @resultlist = client.execute(
            api_method: service.events.list,
            parameters: {
              calendarId: @user.calendar_id,
              maxResults: 30,
              # timeZone: "America/Chicago",
              orderBy: "startTime",
              singleEvents: true,
              timeMin: "2013-01-01T00:00:00-0500"}
              # timeMin: "2013-06-10T00:00:00-0500",
              # timeMax: "2013-06-11T00:00:00-0500"}
              # timeMin: Time.now.beginning_of_day.strftime("%Y-%m-%dT%H:%M:%S"),
              # timeMax: "2013-06-06T23:59:00-0500"}
            )

        # .strftime("%Y-%m-%d %H:%M:%S")

        # Saves Google calendar events to database
        if @resultlist.data["items"][0] != nil
           @resultlist.data["items"].each do |item|
            if item["start"]["dateTime"] > Time.now.beginning_of_day && item["end"]["dateTime"] < Time.now.beginning_of_day.tomorrow
                event = Event.new
                event.title = "EVENT: " + item["summary"].upcase
                event.start = item["start"]["dateTime"]
                event.end = item["end"]["dateTime"]
                event.notes = nil
                event.priority = "1 = High"
                event.duration = (event.end - event.start).to_i
                event.task = false
                event.user_id = User.find(session[:user_id])
                event.save
            end # if
           end # do
        end # !=nil
    end # == nil

    ## ADDS IN FREE TIME ##
    sort_direction = params["sortby"]
    if sort_direction == nil
      sort_direction = "asc"
    end
    @events = Event.where(task: false).order("start #{sort_direction}")
    @tasks = Event.where(task: true).order("priority asc")
    @free_time = Event.where(title: "FREE TIME").order("start asc")

    # Free slots in between events
    # if Event.find_by_task(nil) == nil && @free_time != nil && @events != nil && @tasks != nil
        i = 0
        @events.each do |t|  #This is starting from 0.  Needs to start at 1.
          if @events[i+1] != nil
            free_slot = Event.new
            free_slot.title = "Free Time".upcase
            free_slot.start = t.end
            free_slot.end = @events[i+1].start
            free_slot.duration = (free_slot.end - free_slot.start).to_i
            free_slot.priority = "1 = High"
            # free_slot.task = false
            free_slot.save
            i = i+1
          elsif @events[i+1] != nil && @events[i] != nil
            free_slot = Event.new
            free_slot.title = "Free Time".upcase
            free_slot.start = t.end
            free_slot.end = @events[i+1].start
            free_slot.duration = (free_slot.end - free_slot.start).to_i
            free_slot.priority = "1 = High"
            # free_slot.task = false
            free_slot.save
         end
        end

        # Free slot beginning of day
        if @events.first != nil
          f = @events.first
          first_free_slot = Event.new
          first_free_slot.title = "Free Time".upcase
          start = Time.now.beginning_of_day.to_i + (8*60*60) # This starts free time at 8:00 AM
          first_free_slot.start = Time.at(start)
          first_free_slot.end = f.start
          first_free_slot.duration = (first_free_slot.end - first_free_slot.start).to_i
          first_free_slot.priority = "1 = High"          # first_free_slot.task = false
          first_free_slot.save
        end

        # Free slot end of day
        if @events.last != nil
          l = @events.last
          last_free_slot = Event.new
          last_free_slot.title = "Free Time".upcase
          last_free_slot.start = l.end
          last_free_slot.end = Time.now.beginning_of_day.tomorrow
          last_free_slot.duration = (last_free_slot.end - last_free_slot.start).to_i
          last_free_slot.priority = "1 = High"
          # last_free_slot.task = false
          last_free_slot.save
        end

        ## Slot in tasks ##
        z = 0
        j = 0
        @tasks.each do |t|
          @free_time.each do |ff|
            if @tasks[z+1] != nil && @free_time[j+1] != nil
              if @tasks[z].duration <= @free_time[j].duration
                slot_task = Event.new
                slot_task.title = "#{@tasks[z].title}"
                slot_task.start = @free_time[j].start
                end_time = @free_time[j].start.to_i + (@tasks[z].duration * 60)
                slot_task.end = Time.at(end_time)
                slot_task.duration = (slot_task.end - slot_task.start).to_i
                slot_task.priority = "if"
                slot_task.task = false
                slot_task.save

                @free_time[j].start = slot_task.end
                @free_time[j].end = @free_time[j].end
                @free_time[j].duration = (@free_time[j].end - @free_time[j].start).to_i
                # new_free_time.task = false
                @free_time[j].save
                if @tasks[z+1] == nil
                  break
                else
                  z = z + 1
                end
              else
                j = j + 1
                slot_task = Event.new
                slot_task.title = "#{@tasks[z].title}"
                slot_task.start = @free_time[j].start
                end_time = @free_time[j].start.to_i + (@tasks[z].duration * 60)
                slot_task.end = Time.at(end_time)
                slot_task.duration = (slot_task.end - slot_task.start).to_i
                slot_task.priority = "else"
                slot_task.task = false
                slot_task.save

                @free_time[j].start = slot_task.end
                @free_time[j].end = @free_time[j].end
                @free_time[j].duration = @free_time[j].end - @free_time[j].start
                # new_free_time.t+1ask = false
                @free_time[j].save
                z = z+1
              end
            end
            if @tasks[z+1] == nil && @tasks[z] == @tasks.last
               if @tasks[z].duration <= @free_time[j].duration
                  slot_task = Event.new
                  slot_task.title = "#{@tasks[z].title}"
                  slot_task.start = @free_time[j].start
                  end_time = @free_time[j].start.to_i + (@tasks[z].duration * 60)
                  slot_task.end = Time.at(end_time)
                  slot_task.duration = (slot_task.end - slot_task.start).to_i
                  slot_task.priority = "last"
                  slot_task.task = false
                  slot_task.save

                  @free_time[j].start = slot_task.end
                  @free_time[j].end = @free_time[j].end
                  @free_time[j].duration = (@free_time[j].end - @free_time[j].start).to_i
                  # new_free_time.task = false
                  @free_time[j].save
                  break
                # else
                  # give a notice that the final task was not able to be added
                end
                break
             end
             break
           end
          end

        # end #if Event.find_by_task(nil) == nil && @free_time != nil && @events != nil && @tasks != nil

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
      if t.task == nil
        t.destroy
      end
    end
    redirect_to "/see_tasks"
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
    @event.start = Time.now
    @event.end = Time.now
    @event.user_id = User.find(session[:user_id])
    if @event.save
      redirect_to "/see_tasks"
    else
      redirect_to "/see_tasks", notice: "Please fill in the required information"
    end
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
    redirect_to "/see_tasks"
  end

  def destroy
    @event = Event.find_by_id(params[:id])
    @event.destroy
    redirect_to "/see_tasks"
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

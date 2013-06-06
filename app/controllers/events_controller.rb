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
    sort_direction = params["sortby"]
    if sort_direction == nil
      sort_direction = "asc"
    end
    @events = Event.where(:task => false).order("start #{sort_direction}").limit(100)

    # # Free slot beginning of day
    # f = @events.first
    # first_free_slot = Event.new
    # first_free_slot.title = "Free Time".upcase
    # first_free_slot.start = Time.now.beginning_of_day
    # first_free_slot.end = f.start
    # first_free_slot.duration = first_free_slot.end - first_free_slot.start
    # first_free_slot.task = false
    # first_free_slot.save

    # Free slots in between events
    i = 0
    @events.each do |t|
      if @events[i+1] != nil
        free_slot = Event.new
        free_slot.title = "Free Time".upcase
        free_slot.start = t.end
        free_slot.end = @events[i+1].start
        free_slot.duration = free_slot.end - free_slot.start
        free_slot.task = false
        free_slot.save
        i = i+1
       end
    end

    # Free slot end of day
    l = @events.last
    last_free_slot = Event.new
    last_free_slot.title = "Free Time".upcase
    last_free_slot.start = l.end
    last_free_slot.end = Time.now.end_of_day
    last_free_slot.duration = last_free_slot.end - last_free_slot.start
    last_free_slot.task = false
    last_free_slot.save

    redirect_to "/events"
  end



  # def add_tasks
  #   sort_direction = params["sortby"]
  #   if sort_direction == nil
  #     sort_direction = "asc"
  #   end
  #   @events = Event.where(:task => false).order("start #{sort_direction}").limit(100)
  #   @events_tasks = Event.where(:task => true).order("priority #{sort_direction}").limit(100)

  #   @free = Array.new

  #   @events.each do |t|
  #       if t.start > Time.now.beginning_of_day
  #           free_slot = Event.new
  #           free_slot.start = Time.now.beginning_of_day
  #           free_slot.end = t.start
  #           free_slot.duration = free_slot.end - free_slot.start
  #           @free[@free.length] = free_slot
  #           break
  #       end
  #   end

  #   i = 0
  #   @events.each do |t|
  #     if @events[i+1] != nil
  #       free_slot = Event.new
  #       free_slot.title = "Free Slot"
  #       free_slot.start = t.end
  #       free_slot.end = @events[i+1].start   # THIS IS WHERE THE ISSUE IS
  #       free_slot.duration = free_slot.end - free_slot.start
  #       free_slot.task = false
  #       free_slot.save
  #       i = i+1
  #      end
  #   end

  #   i = 0
  #  @events.each do |t|
  #       if t.end < Time.now.end_of_day
  #           free_slot = Event.new
  #           free_slot.start = t.end
  #           free_slot.end = Time.now.end_of_day
  #           free_slot.duration = free_slot.end - free_slot.start
  #           @free[@free.length] = free_slot
  #           break
  #       end
  #   end


  #  i = 0
  #  @events.each do |t|
  #     # j = 0
  #     @free.each do |f|
  #         if t.duration < f.duration
  #             # create event
  #                slotted_task = Event.new
  #                slotted_task.title = "TASK: #{slotted_task.title.upcase}"
  #                slotted_task.start = f.start
  #                end_time = f.start.to_i + (slotted_task.duration * 60) #this will give me the number of minutes
  #                slotted_task.end = slotted_task.at(end_time)
  #                slotted_task.notes = slotted_task.notes
  #                slotted_task.task = false
  #                slotted_task.user_id = User.find(session[:user_id])
  #                slotted_task.save
  #             # Modify @free array
  #                 free_slot = f
  #                 free_slot.start = slotted_task.end
  #                 free_slot.duration = free_slot.end - free_slot.start
  #                 @free[@free.length] = free_slot
  #                 break
  #             break
  #         end
  #     # j = j+1
  #     end
  #     i = i+1
  #  end


  #   # Own work
  #   # @work_start = Time.now.beginning_of_day
  #   # @work_end = Time.now.end_of_day
  #   # @events.each_cons(2) {|previous| current}
  #   #    free_time = Event.new
  #   #    free_time.title = "Free Time #{current}"
  #   #    if current == @events.first
  #   #       free_time.start = "@work_start"
  #   #       free_time.end = current.start
  #   #    end
  #   #    if current == @events.last
  #   #       free_time.start = current.end
  #   #       free_time.end = "@work_end"
  #   #    end
  #   #    if current != @events.first || @events.last
  #   #       free_time.start = previous.end
  #   #       free_time.end = current.start
  #   #    end
  #   #    free_time.notes = nil
  #   #    free_time.task = false
  #   #    free_time.user_id = User.find(session[:user_id])
  #   #    free_time.save



  #   # Slot in tasks by creating events, then subsequently destroying the free time event
  #   # Slot in task (block)
  #   #   if within free time
  #   #     create it
  #   #   else
  #   #     add what you can
  #   #     create rest of event in next available free time
  #   #   end
  #   # end

  #   ## What am I trying to do???
  #   # Analyze the existing events (from Google), and find the gaps between 8AM, the events, and 12AM
  #   # go through the list of tasks (ascended by priority, then due date if present), then make them into events

  #   # @events_tasks.each do |t|
  #   #   if t.task == true
  #   #    @event = Event.new
  #   #    @event.title = "TASK: #{t.title.upcase}"
  #   #    @event.start = "2013-05-31T08:00:00-05:00"
  #   #    end_time = @event.start.to_i + (t.duration * 60) #this will give me the number of minutes
  #   #    @event.end = Time.at(end_time)
  #   #    @event.notes = t.notes
  #   #    @event.task = false
  #   #    @event.user_id = User.find(session[:user_id])
  #   #    @event.save
  #   #   end
  #   # end

  #   redirect_to "/events"
  # end





  def google_events
    @user = User.find(session[:user_id])
    client = Google::APIClient.new
    client.authorization.access_token = @user.token
    service = client.discovered_api('calendar', 'v3')
    @resultlist = client.execute(
        api_method: service.events.list,
        parameters: {
          calendarId: @user.calendar_id,
          # maxResults: 3,
          timeZone: "America/Chicago",
          timeMin: "2013-06-06T08:00:00-0500",
          timeMax: "2013-06-06T23:59:00-0500"}
        )

    # Saves Google calendar events to database
    @resultlist.data["items"].each do |item|
      # if item["start"]["dateTime"] > Time.now.beginning_of_day && item["end"]["dateTime"] < Time.now.end_of_day

      ####
      # NEED TO FIGURE OUT HOW TO FILTER WHICH GOOGLE EVENTS TO SAVE (I.E. BEGINNING AND END_OF_DAY)
      ####
      event = Event.new
      event.title = item["summary"]
      event.start = item["start"]["dateTime"]
      event.end = item["end"]["dateTime"]
      event.notes = nil
      event.task = false
      event.user_id = User.find(session[:user_id])
      event.save
      # end
    end

    ## ADDS IN FREE TIME ##
    sort_direction = params["sortby"]
    if sort_direction == nil
      sort_direction = "asc"
    end
    @events = Event.where(:task => false).order("start #{sort_direction}").limit(100)

    # # Free slot beginning of day
    # f = @events.first
    # first_free_slot = Event.new
    # first_free_slot.title = "Free Time".upcase
    # first_free_slot.start = Time.now.beginning_of_day
    # first_free_slot.end = f.start
    # first_free_slot.duration = first_free_slot.end - first_free_slot.start
    # first_free_slot.task = false
    # first_free_slot.save

    # Free slots in between events
    i = 0
    @events.each do |t|
      if @events[i+1] != nil
        free_slot = Event.new
        free_slot.title = "Free Time".upcase
        free_slot.start = t.end
        free_slot.end = @events[i+1].start
        free_slot.duration = free_slot.end - free_slot.start
        free_slot.task = false
        free_slot.save
        i = i+1
       end
    end

    # Free slot end of day
    l = @events.last
    last_free_slot = Event.new
    last_free_slot.title = "Free Time".upcase
    last_free_slot.start = l.end
    last_free_slot.end = Time.now.end_of_day
    last_free_slot.duration = last_free_slot.end - last_free_slot.start
    last_free_slot.task = false
    last_free_slot.save


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

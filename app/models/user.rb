class User < ActiveRecord::Base

  has_many :events, :dependent => :destroy

  # def self.from_omniauth(auth)
  #   if auth["uid"] == User.find_by_uid(auth["uid"])
  #     u = User.find_by_uid(auth["uid"])
  #     u.provider = auth["provider"]
  #     u.uid = auth["uid"]
  #     u.email = "test"
  #     u.calendar_id = auth["info"]["email"]
  #     u.token = auth["credentials"]["token"]
  #     u.save
  #   else
  #     create_from_omniauth(auth)
  #   end
  # end

  def self.from_omniauth(auth)
    if User.find_by_uid(auth.slice["uid"])
      u = User.find_by_uid(auth.slice["uid"])
      u.token = auth["credentials"]["token"]
      u.save
    else
      create_from_omniauth(auth)
    end
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.email = auth["info"]["email"]
      user.token = auth["credentials"]["token"]
      user.calendar_id = auth["info"]["email"]
    end
  end

end

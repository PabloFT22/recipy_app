class TagsController < ApplicationController
  def search
    tags = current_user.tags
      .where("name LIKE ?", "%#{params[:q].to_s.strip.downcase}%")
      .alphabetical
      .limit(10)

    render json: tags.map { |t| { id: t.id, name: t.name } }
  end
end

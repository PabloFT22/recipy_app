class TagsController < ApplicationController
  def search
    tags = current_user.tags
      .where(Tag.arel_table[:name].matches("%#{Tag.sanitize_sql_like(params[:q].to_s.strip.downcase)}%"))
      .alphabetical
      .limit(10)

    render json: tags.map { |t| { id: t.id, name: t.name } }
  end
end

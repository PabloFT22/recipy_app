class MealPlansController < ApplicationController
  before_action :set_meal_plan, only: [:show, :edit, :update, :destroy, :generate_grocery_list, :use_as_template, :clone_from_template, :export_ical]

  def index
    @meal_plans = current_user.meal_plans.recent.page(params[:page])
    @active_meal_plan = current_user.meal_plans.active.first
  end

  def show
    @recipes_by_date = @meal_plan.recipes_by_date
  end

  def new
    @meal_plan = current_user.meal_plans.build(
      start_date: Date.current.beginning_of_week,
      end_date: Date.current.end_of_week
    )
  end

  def create
    @meal_plan = current_user.meal_plans.build(meal_plan_params)

    if @meal_plan.save
      redirect_to @meal_plan, notice: 'Meal plan was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @meal_plan.update(meal_plan_params)
      redirect_to @meal_plan, notice: 'Meal plan was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meal_plan.destroy
    redirect_to meal_plans_url, notice: 'Meal plan was successfully deleted.'
  end

  def generate_grocery_list
    @grocery_list = @meal_plan.generate_grocery_list
    redirect_to @grocery_list, notice: 'Grocery list generated from meal plan!'
  end

  def use_as_template
    @meal_plan.update(is_template: true)
    redirect_to @meal_plan, notice: 'Meal plan saved as template.'
  end

  def clone_from_template
    new_start = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_week
    new_plan = @meal_plan.clone_to(new_start)
    redirect_to new_plan, notice: 'Meal plan cloned from template.'
  end

  def export_ical
    require 'icalendar'

    cal = Icalendar::Calendar.new
    cal.append_custom_property("X-WR-CALNAME", @meal_plan.name)

    @meal_plan.meal_plan_recipes.includes(:recipe).each do |mpr|
      next unless mpr.scheduled_for.present?

      event = Icalendar::Event.new
      ical_date = Icalendar::Values::Date.new(mpr.scheduled_for.strftime('%Y%m%d'))
      event.dtstart = ical_date
      event.dtend = ical_date
      event.summary = [mpr.meal_type&.capitalize, mpr.recipe.title].compact.join(': ')
      event.description = mpr.recipe.description
      cal.add_event(event)
    end

    cal.publish

    send_data cal.to_ical,
              filename: "#{@meal_plan.name.parameterize}.ics",
              type: 'text/calendar',
              disposition: 'attachment'
  end

  private

  def set_meal_plan
    @meal_plan = current_user.meal_plans.find(params[:id])
  end

  def meal_plan_params
    params.require(:meal_plan).permit(:name, :start_date, :end_date, :is_template)
  end
end

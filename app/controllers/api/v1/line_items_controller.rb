class Api::V1::LineItemsController < ApplicationController
  before_action :authenticate_user

  # --------------------------------------------
  # GET /line_items
  # --------------------------------------------
  def index
    line_items = current_user.line_items
    render json: LineItemSerializer.serialize_collection(line_items)
  end

  # --------------------------------------------
  # GET /line_items/:id
  # --------------------------------------------
  def show
    render json: LineItemSerializer.new(line_item)
  end

  # --------------------------------------------
  # PUT /line_items/:id
  # --------------------------------------------
  def update
    if line_item.update(update_params)
      render json: LineItemSerializer.new(line_item).as_json
    else
      render_error(line_item.errors.full_messages, status: :unprocessable_entity)
    end
  end

  # --------------------------------------------
  # DELETE /line_items/:id
  # --------------------------------------------
  def destroy
    line_item.destroy
    head :no_content
  end

  private

  def update_params
    params.permit(:item_type, :category, :amount_cents, :description)
  end

  def line_item
    @line_item ||= current_user.line_items.find(params[:id])
  end
end

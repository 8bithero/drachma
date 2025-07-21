class Api::V1::Statements::LineItemsController < ApplicationController
  before_action :authenticate_user

  # --------------------------------------------
  # POST /statements/:slug/line_items
  # --------------------------------------------
  def create
    result = LineItemsCreateService.call(params: {
      user: current_user,
      slug: params[:statement_slug],
      line_items: create_params
    })

    if result.success?
      render json: StatementSerializer.new(result.value!, include_line_items: true),
             status: :created
    else
      render_error(result.failure, status: :unprocessable_entity)
    end
  end

  # --------------------------------------------
  # GET /statements/:slug/line_items
  # --------------------------------------------
  def index
    statement = current_user.statements
                            .includes(:line_items)
                            .find_by(slug: params[:statement_slug])

    if statement
      render json: {
        line_items: LineItemSerializer.serialize_collection(statement.line_items),
        statement: StatementSerializer.new(statement)
      }
    else
      error_msg = "Statement for #{params[:statement_slug]} not found"
      render_error(error_msg, status: :not_found)
    end
  end

  private

  def create_params
    params.require(:line_items).map do |item|
      item.permit(:item_type, :category, :amount_cents, :description)
    end
  end
end

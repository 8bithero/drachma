class Api::V1::StatementsController < ApplicationController
  before_action :authenticate_user

  def index
    statements = current_user.statements
    statements = statements.includes(:line_items) if include_line_items?
    statements = statements.order(slug: :desc)

    render json: StatementSerializer.serialize_collection(
      statements,
      include_line_items: include_line_items?
    )
  end

  def show
    statement = current_user.statements
                            .yield_self { |scope| include_line_items? ? scope.includes(:line_items) : scope }
                            .find_by(slug: params[:slug])

    if statement
      render json: StatementSerializer.new(statement, include_line_items: include_line_items?)
    else
      error_msg = "Statement for #{params[:slug]} not found"
      render_error(error_msg, status: :not_found)
    end
  end

  private

  def include_line_items?
    ActiveModel::Type::Boolean.new.cast(params[:include_line_items])
  end
end

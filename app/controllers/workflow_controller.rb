class WorkflowController < ApplicationController
  before_filter :require_user
  layout 'workflow'
end

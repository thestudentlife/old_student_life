class WorkflowController < ApplicationController
  before_filter :require_user
  responders :flash
  layout 'workflow'
end

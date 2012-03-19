module Espresso
  class Paginator
    def self.paginate(params, query)
      query.page(params[:page]).per(params[:per_page] || 20)  
    end
  end
end
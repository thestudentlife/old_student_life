class PhotoSetAdmin < ArticleAdmin
  def actions
    {
      "Show" => lambda { |article| "/workflow/photo_sets/" + article.id.to_s }
    }
  end
end
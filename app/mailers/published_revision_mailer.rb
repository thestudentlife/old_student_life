class PublishedRevisionMailer < ActionMailer::Base
  default :from => "from@example.com"
  
  def revision_email (revision)
    attachments["#{revision.title}.html"] = revision.body
    mail (:to => "mchtly@gmail.com", :subject => revision.title )
  end
end

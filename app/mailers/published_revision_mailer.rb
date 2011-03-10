class PublishedRevisionMailer < ActionMailer::Base
  default :from => "from@example.com"
  
  def revision_email (revision)
    attachments["#{revision.title}.incx"] = InCopy.html_to_incopy(revision.body)
    mail (:to => "mchtly@gmail.com", :subject => revision.title )
  end
end

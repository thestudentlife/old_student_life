namespace :dummy do
  task :admin => :environment do
    User.create(
      :email => "admin@tsl.pomona.edu",
      :password => "password",
      :password_confirmation => "password",
      :is_admin => true)
  end
  task :load => :environment do
    news = Section.create(:name => "News", :priority => 10)
    opinions = Section.create(:name => "Opinions", :priority => 100)
    
    open = WorkflowStatus.create(:name => "Open")
    edited_by_section = WorkflowStatus.create(:name => "Edited by Section")
    edited_by_management = WorkflowStatus.create(:name => "Edited by Management")
    
    writer = User.create(
        :email => "writer@tsl.pomona.edu",
        :password => "password",
        :password_confirmation => "password")
    writer2 = User.create(
        :email => "writer2@tsl.pomona.edu",
        :password => "password",
        :password_confirmation => "password")
    editor = User.create(
        :email => "editor@tsl.pomona.edu",
        :password => "password",
        :password_confirmation => "password",
        :sections => [news])
    admin = User.create(
      :email => "admin@tsl.pomona.edu",
      :password => "password",
      :password_confirmation => "password",
      :is_admin => true)
    
    billgates = Article.create(
      :working_name => "Bill Gates",
      :section => news,
      :workflow_status => open,
      :authors => [])
    
    geeky = Revision.create(
      :article => billgates,
      :author => writer2,
      :title => "Bill Gates Remains Geeky and Uncool Despite Personal Fortune Larger Than GDP of Small Country, Say Experts",
      :body => "Hahah **hah**",
      :published_online => true,
      :published_online_at => Time.now)
    
    smiley = Article.create(
      :working_name => "Smiley 80s",
      :section => news,
      :workflow_status => open,
      :authors => [],
      :open_to_author => false)
    smiley_head = Headline.create(
      :article => smiley,
      :priority => 10)
    
    ellie = WorkflowComment.create(
      :article => smiley,
      :author => editor,
      :visible_to_article_author => true,
      :text => "You should talk to Ellie Ash") 
    
    r1 = Revision.create(
      :article => smiley,
      :author => writer,
      :visible_to_article_author => true,
      :title => "Smiley 80s should be fun",
      :body => "This is body text",
      :published_online => true,
      :published_online_at => Time.now)
    
    meeting = WorkflowComment.create(
      :article => smiley,
      :author => editor,
      :visible_to_article_author => true,
      :text => "Please come in at 8PM Tuesday")
      
    sucks = WorkflowComment.create(
      :article => smiley,
      :author => editor,
      :visible_to_article_author => false,
      :text => "Yo.. this article needs a lot of work")
  end
end

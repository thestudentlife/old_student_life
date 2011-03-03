namespace :dummy do
  task :load => :environment do
    news = Section.create(:name => "News", :priority => 10)
    opinions = Section.create(:name => "Opinions", :priority => 100)
    
    open = WorkflowStatus.create(:name => "Open", :priority => 10)
    edited_by_section = WorkflowStatus.create(:name => "Open", :priority => 10)
    edited_by_management = WorkflowStatus.create(:name => "Open", :priority => 10)
    
    writer = StaffMember.create :user => User.create(
        :email => "writer@tsl.pomona.edu",
        :password => "password",
        :password_confirmation => "password")
    writer2 = StaffMember.create :user => User.create(
        :email => "writer2@tsl.pomona.edu",
        :password => "password",
        :password_confirmation => "password")
    editor = StaffMember.create :user => User.create(
        :email => "editor@tsl.pomona.edu",
        :password => "password",
        :password_confirmation => "password"),
        :sections => [news]
    admin = StaffMember.create :user => User.create(
      :email => "admin@tsl.pomona.edu",
      :password => "password",
      :password_confirmation => "password"),
      :is_admin => true
    
    smiley = Article.create(
      :working_name => "Smiley 80s",
      :section => news,
      :workflow_status => open,
      :authors => [writer, editor])
    billgates = Article.create(
      :working_name => "Bill Gates",
      :section => news,
      :workflow_status => open,
      :authors => [writer2])
     
    ellie = WorkflowComment.create(
      :article => smiley,
      :visible_to_author => true,
      :text => "You should talk to Ellie Ash") 
    
    r1 = Revision.create(
      :article => smiley,
      :visible_to_author => true,
      :title => "Smiley 80s should be fun",
      :body => "This is body text")
    
    meeting = WorkflowComment.create(
      :article => smiley,
      :visible_to_author => true,
      :text => "Please come in at 8PM Tuesday")
  end
end
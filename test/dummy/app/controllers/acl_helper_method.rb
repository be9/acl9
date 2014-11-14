class ACLHelperMethod < ApplicationController
  access_control :helper => :foo? do
    allow :owner, :of => :foo
  end

  def allow
    @foo = Foo.first

    render inline: "<div><%= foo? ? 'OK' : 'AccessDenied' %></div>"
  end
end

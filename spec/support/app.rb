class FaxSection < SitePrism::Section
  element :title, '.title'
  element :phone, '.phone'
  element :created_at, '.created_at'
  element :state, '.state'
end

class FaxesPage < SitePrism::Page
  set_url '/faxes'

  sections :faxes, FaxSection, '.fax'
end

class App
  def faxes_page
    FaxesPage.new
  end
end

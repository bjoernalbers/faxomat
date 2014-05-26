class FaxSection < SitePrism::Section
  element :title, '.title'
  element :phone, '.phone'
  element :created_at, '.created_at'
  element :state, '.state'
end

class FaxesPage < SitePrism::Page
  set_url '/faxes'

  sections :faxes, FaxSection, '.fax'

  def has_fax?(fax)
    faxes.any? { |f| f.has_css?("#fax_#{fax.id}") }
  end
end

class AbortedFaxesPage < FaxesPage
  set_url '/faxes/aborted'
end

class App
  def faxes_page
    FaxesPage.new
  end
end

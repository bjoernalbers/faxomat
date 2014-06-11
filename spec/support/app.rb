class FaxSection < SitePrism::Section
  element :title, '.title'
  element :phone, '.phone'
  element :created_at, '.created_at'
  element :state, '.state'
end

class FaxesPage < SitePrism::Page
  set_url '/faxes'
  set_url_matcher /faxes\/?/

  sections :faxes, FaxSection, '.fax'

  def has_fax?(fax)
    faxes.any? { |f| f.has_css?("#fax_#{fax.id}") }
  end
end

class AbortedFaxesPage < FaxesPage
  set_url '/faxes/aborted'
  set_url_matcher /faxes\/aborted\/?/
end

class SearchFaxesPage < FaxesPage
  set_url '/faxes/search{?q*}'
  set_url_matcher /faxes\/search\/?/
end

class App
  def faxes_page
    FaxesPage.new
  end

  def aborted_faxes_page
    AbortedFaxesPage.new
  end
end

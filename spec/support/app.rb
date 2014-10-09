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

class UndeliverableFaxesPage < FaxesPage
  set_url '/faxes/undeliverable'
  set_url_matcher /faxes\/undeliverable\/?/
end

class SearchFaxesPage < FaxesPage
  set_url '/faxes/search{?q*}'
  set_url_matcher /faxes\/search\/?/
end

class App
  def faxes_page
    FaxesPage.new
  end

  def undeliverable_faxes_page
    UndeliverableFaxesPage.new
  end
end

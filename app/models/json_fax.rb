class JsonFax
  def process(json)
    json = JSON.parse(json)
    Fax.new phone: json['phone'], patient: json['patient'], path: json['path']
  end
end

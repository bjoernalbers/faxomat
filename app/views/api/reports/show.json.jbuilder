json.extract! @report, :id
json.pdf_url  api_report_url(@report, format: :pdf)

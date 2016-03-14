json.extract! @report, :id
json.message @message
json.errors @report.errors.full_messages if @report.errors.present?
json.pdf_url api_report_url(@report, format: :pdf) if @report.persisted? # TODO: Remove!

json.extract!(@faxes.count_by_status, :completed, :aborted, :active)

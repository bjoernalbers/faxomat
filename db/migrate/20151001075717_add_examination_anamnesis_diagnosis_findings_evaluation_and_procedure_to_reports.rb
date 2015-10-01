class AddExaminationAnamnesisDiagnosisFindingsEvaluationAndProcedureToReports < ActiveRecord::Migration
  def up
    add_column :reports, :examination, :text
    add_column :reports, :anamnesis, :text
    add_column :reports, :diagnosis, :text
    add_column :reports, :findings, :text
    add_column :reports, :evaluation, :text
    add_column :reports, :procedure, :text

    change_column :reports, :anamnesis, :text, null: false
    change_column :reports, :evaluation, :text, null: false
    change_column :reports, :procedure, :text, null: false
  end

  def down
    remove_column :reports, :examination, :text
    remove_column :reports, :anamnesis, :text
    remove_column :reports, :diagnosis, :text
    remove_column :reports, :findings, :text
    remove_column :reports, :evaluation, :text
    remove_column :reports, :procedure, :text
  end
end

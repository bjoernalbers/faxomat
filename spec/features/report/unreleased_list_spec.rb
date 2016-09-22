# In order to ensure that every report gets released
# as an authorized user
# I want to see all unreleased reports signed by unauthorized users.

feature 'Unreleased Reports List' do
  let(:user) { create(:user) }
  let(:tab) { 'Unveröffentlicht' }

  before do
    login_as user, scope: :user
  end

  def visit_list
    visit root_url
    click_link 'Arztbriefe'
    click_link tab
  end

  scenario 'navigation' do
    visit_list

    expect(current_path).to eq reports_path
    within('#navbar') do
      expect(find('.active').text).to eq 'Arztbriefe'
    end
    within('#reports_nav') do
      expect(find('.active').text).to eq tab
    end
  end

  scenario 'content' do
    pending_report = create(:pending_report, user: user)
    verified_report = create(:verified_report, user: user)
    report = create(:unreleased_report)

    visit_list

    expect(page).not_to have_content(pending_report.title)
    expect(page).not_to have_content(verified_report.title)
    expect(page).to have_content(report.title)

    visit report_url(report)
    click_button 'Vidieren'

    visit_list
    expect(page).not_to have_content(report.title)

    visit report_url(report)
    expect(page).not_to have_button 'Vidieren'
    expect(page).to have_content 'Vidiert'
  end
end

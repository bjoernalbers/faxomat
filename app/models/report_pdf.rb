require 'prawn/measurement_extensions'

class ReportPdf
  include Prawn::View

  attr_reader :report, :recipient, :template

  def initialize(document, template = Template.default)
    @report = document.report
    @recipient = document.recipient
    @template = template
  #def initialize(opts)
    #@report    = opts.fetch(:report)
    #@recipient = opts.fetch(:recipient)
    #@template  = opts.fetch(:template) { Template.default }

    # NOTE: This sets the default page size and stuff.
    # See: https://github.com/prawnpdf/prawn/issues/802
    @document = Prawn::Document.new(
      page_size: 'A4',
      page_layout: :portrait,
      left_margin: 25.mm,
      right_margin: 20.mm,
      background_color: 'FFFFFF')

    build_report
  end

  # TODO: Split report generation into smaller pieces!
  def build_report
    set_default_font

    if watermark
      create_stamp("stamp") do
        fill_color "cc0000"
        text_box watermark,
          :size   => 2.cm,
          :width  => bounds.width,
          :height => bounds.height,
          :align  => :center,
          :valign => :center,
          :at     => [0, bounds.height],
          :rotate => -45,
          :rotate_around => :center
      end

      repeat(:all) do
        stamp("stamp")
      end
    end

    #bounding_box [80.mm, bounds.absolute_top - 10.mm], width: 100.mm, height: 35.mm do
    bounding_box [0, bounds.absolute_top - 10.mm], width: 80.mm, height: 35.mm do
      #stroke_bounds
      text template.title, size: 10, style: :bold
      text template.subtitle, align: :left, size: 10
      text template.short_title, align: :left, size: 8.pt, style: :italic

      move_down font.height * 0.5

      text template.slogan, size: 8.pt, aligh: :left
    end


    text_box template.owners, at: [80.mm, bounds.absolute_top - 10.mm],
      width: 65.mm, height: 35.mm, align: :right, size: 12

    # Logo
    bounding_box [145.mm, bounds.absolute_top - 10.mm], width: 25.mm, height: 25.mm do
      if template.logo.present?
        #image Rails.root.join('app', 'assets', 'images', 'logo.png'),
        image template.logo.path, width: 25.mm, align: :center, valign: :top
      end
    end

    move_down font.height * 0.5

    text template.contact_infos, align: :center, size: 9.pt

    stroke_horizontal_rule

    # Return address
    bounding_box [0, bounds.absolute_top - 45.mm], width: 80.mm do
      text template.return_address, align: :center, size: 8.pt
      line_width 0.5.pt
      stroke_horizontal_rule
    end

    bounding_box [0, bounds.absolute_top - (45.mm + 18.mm)], width: 80.mm, height: 27.mm do
      text recipient.full_address.join("\n"),
        align: :left,
        size: 10.pt
    end

    bounding_box [100.mm, bounds.absolute_top - 50.mm], width: 75.mm, height: 40.mm do
      text %{Befundender Arzt:}, style: :bold, size: 10.pt
      text report.physician_name, size: 10.pt

      move_down font.height

      text %{Patient:}, style: :bold, size: 10.pt
      text report.patient_name, size: 10.pt

      move_down font.height

      text %{Datum:}, style: :bold, size: 10.pt
      #text %{12. Mai 2015}, size: 10.pt
      text report.report_date, size: 10.pt
    end

    move_down 8.5.mm

    # TODO: Der restliche text sollte auch in eine Bounding box, oder?

    text report.subject, style: :bold, size: 11.pt

    move_down font.height * 2

    text recipient.salutation, size: 11.pt

    move_down font.height

    text "vielen Dank für die Überweisung Ihres Patienten #{report.patient_name}.", size: 11.pt

    move_down font.height

    %i(anamnesis procedure clinic findings evaluation).each do |method|
      if @report.send(method).present?
        text Report.human_attribute_name(method) + ':', style: :bold, size: 11.pt
        text @report.send(method), size: 11.pt
        move_down font.height
      end
    end

    move_down font.height

    text %{Mit freundlichen Grüßen}, size: 11.pt

    if report.include_signature?
      report.signings.each_with_index do |signing,index|
        move_down font.height
        if signing.signature_path.present?
          image signing.signature_path, height: 2*font.height
        end
        text signing.full_name, size: 11.pt
        text signing.suffix, size: 11.pt
      end
    end
  end

  def watermark
    case report.status
    when :pending  then 'ENTWURF'
    when :canceled then 'STORNIERT'
    end
  end

  def filename
    [report.model_name.human, report.id, watermark].compact.join('-') + '.pdf'
  end

  # TODO: Add tests!
  def to_file
    render_file(path)
    file = File.open(path)
    if block_given?
      yield file
      File.delete(path)
      nil
    else
      file
    end
  end

  private

  def path
    @path ||= Rails.root.join('tmp', filename).to_s
  end

  def set_default_font
    font_families.update 'DejaVuSans' => {
      normal:      Rails.root + 'app/fonts/dejavu/DejaVuSans.ttf',
      italic:      Rails.root + 'app/fonts/dejavu/DejaVuSans-Oblique.ttf',
      bold:        Rails.root + 'app/fonts/dejavu/DejaVuSans-Bold.ttf',
      bold_italic: Rails.root + 'app/fonts/dejavu/DejaVuSans-BoldOblique.ttf'
    }
    font 'DejaVuSans'
  end
end

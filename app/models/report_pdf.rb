require 'prawn/measurement_extensions'

# TODO: Render by default in DIN A4!
#opts = {
#  page_size: 'A4',
#  page_layout: :portrait,
#  left_margin: 25.mm,
##  right_margin: 20.mm,
#  background_color: 'FFFFFF',
#}

class ReportPdf
  include Prawn::View

  attr_reader :report

  def initialize(report)
    @report = report
    build_report
  end

  # TODO: Split report generation into smaller pieces!
  def build_report
    if report.watermark
      create_stamp("stamp") do
        fill_color "cc0000"
        text_box report.watermark,
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
      text %{Radiologische Gemeinschaftspraxis},
        size: 14
      text %{im Evangelischen Krankenhaus Lippstadt},
        align: :left,
        size: 10
      text %{Zertifiziert nach DIN EN ISO 9001:2008},
        align: :left,
        size: 8.pt,
        style: :italic

      move_down font.height * 0.5

      text ['Offenes Hochfeld-MRT',
        'Mehrzeilen-Spiral-CT',
        'Digitale 3D-Mammographie',
        'Digitales Röntgen / Sonographie',
        'Digitale Subtraktionsangiographie (DSA)'].join(" \u00b7 "), size: 8.pt, align: :left

    end


    text_box %{Dipl.-Med. Jost Porrmann
      Dr. med. Lars Rühe
      Dr. med. Peter Prodehl
      Ulrike Müller},
      at: [80.mm, bounds.absolute_top - 10.mm],
      #at: [0, bounds.absolute_top - 10.mm],
      #align: :right,
      width: 65.mm,
      height: 35.mm,
      #align: :left,
      align: :right,
      #style: :bold,
      size: 12

    # Logo
    bounding_box [145.mm, bounds.absolute_top - 10.mm], width: 25.mm, height: 25.mm do
      image Rails.root.join('app', 'assets', 'images', 'logo.png'),
        width: 25.mm,
        align: :center,
        valign: :top
    end

    stroke_horizontal_rule
      move_down font.height * 0.5

    text ['Tel: 02941 15015-0', 'Fax: 02941 15015-11', 'Email: info@radiologie-lippstadt.de', 'Web: www.radiologie-lippstadt.de'].join(" \u00b7 "),
      align: :center,
      size: 9.pt

    # Return address
    bounding_box [0, bounds.absolute_top - 45.mm], width: 80.mm do
      text ['Radiol. GP im EVK', 'Wiedenbrücker Str. 33', '59555 Lippstadt'].join(" \u00b7 "),
        align: :center,
        size: 8.pt
      line_width 0.5.pt
      stroke_horizontal_rule
    end

    bounding_box [0, bounds.absolute_top - (45.mm + 18.mm)], width: 80.mm, height: 27.mm do
      text report.recipient_address.join("\n"),
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

    text report.subject, style: :bold

    move_down font.height * 2

    text report.salutation

    move_down font.height

    # Content
    text report.content

    move_down font.height

    text %{Mit freundlichen Grüßen}

    # TODO: Test this!
    if report.include_signature?
      image report.signature_path if report.signature_path.present?
      text report.physician_name
    end
  end
end

require 'prawn/measurement_extensions'

# TODO: Render by default in DIN A4!
#opts = {
#  page_size: 'A4',
#  page_layout: :portrait,
#  left_margin: 25.mm,
##  right_margin: 20.mm,
#  background_color: 'FFFFFF',
#}

class AttendancePdf
  include Prawn::View

  attr_reader :attendance

  def initialize(attendance)
    @attendance = attendance
    build_attendance
  end

  def build_attendance
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

    bounding_box [145.mm, bounds.absolute_top - 10.mm], width: 25.mm, height: 25.mm do
    #bounding_box [0, bounds.absolute_top - 10.mm], width: 25.mm, height: 25.mm do
      #image 'logo.png',
        #width: 25.mm
        #align: :center,
        #valign: :top
    end

    stroke_horizontal_rule
      move_down font.height * 0.5

    text ['Tel: 02941 15015-0', 'Fax: 02941 15015-11', 'Email: info@radiologie-lippstadt.de', 'Web: www.radiologie-lippstadt.de'].join(" \u00b7 "),
      align: :center,
      size: 9.pt

    move_down 8.5.mm

    text 'Anwesenheitsbescheinigung', size: 20.pt

    text attendance.certificate

    # TODO: Der restliche text sollte auch in eine Bounding box, oder?

    #text attendance.subject, style: :bold

    #move_down font.height * 2

    #text attendance.salutation

    #move_down font.height

    # Content
    #text attendance.content

    #move_down font.height

    text %{Mit freundlichen Grüßen}

    # Image of signature
    #image 'unterschrift.png'

    #text attendance.physician_name
  end
end

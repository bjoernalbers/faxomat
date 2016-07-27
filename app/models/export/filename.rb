class Export
  class Filename
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def filename
      "#{title} - #{id}#{suffix}"
    end
    alias to_s filename

    private

    def title
      document.title
    end

    def id
      [ document.model_name.human, document.id ].join(' ')
    end

    def suffix
      Pathname.new(document.path).extname
    end
  end
end

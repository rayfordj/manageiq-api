module Api
  class HrefParser
    def self.parse(href)
      new(href).parse
    end

    def initialize(href)
      @href = href
    end

    def parse
      return [nil, nil] unless href
      if subcollection?
        [subcollection.to_sym, Api.uncompress_id(subcollection_id)]
      else
        [collection.to_sym, Api.uncompress_id(collection_id)]
      end
    end

    private

    attr_reader :href

    def subcollection?
      !!subcollection
    end

    def path
      @path ||= remove_trailing_slashes(fully_qualified? ? URI.parse(href).path : ensure_prefix(href))
    end

    def fully_qualified?
      href =~ /^http/
    end

    def remove_trailing_slashes(str)
      str.sub(/\/*$/, '')
    end

    def ensure_prefix(str)
      result = str.dup
      result.prepend("/")     unless result.start_with?("/")
      result.prepend("/api")  unless result.start_with?("/api")
      result
    end

    def collection
      path_parts[version? ? 3 : 2]
    end

    def collection_id
      path_parts[version? ? 4 : 3]
    end

    def subcollection
      path_parts[version? ? 5 : 4]
    end

    def subcollection_id
      path_parts[version? ? 6 : 5]
    end

    def version?
      @version ||= !!(Api::VERSION_REGEX =~ path_parts[2])
    end

    def path_parts
      @path_parts ||= path.split("/")
    end
  end
end

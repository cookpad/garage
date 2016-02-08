module Garage
  module Docs
    module AnchorBuilding
      def preprocess(full_document)
        reset
        full_document
      end

      def postprocess(full_document)
        reset
        full_document
      end

      private

      def reset
        @anchors = Hash.new(0)
      end

      def to_anchor(text)
        unique_text = text + @anchors[text].to_s
        @anchors[text] += 1

        unique_text.gsub(/\s+/, '-').gsub(/<\/?[^>]*>/, '').downcase
      end
    end
  end
end

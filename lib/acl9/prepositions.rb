module Acl9
  module Prepositions
    VALID_PREPOSITIONS = %i(of for in on at by).freeze unless defined? VALID_PREPOSITIONS

    def _by_preposition options
      object = nil

      VALID_PREPOSITIONS.each do |prep|
        if options[prep]
          raise ArgumentError, "You may only use one preposition to specify object" if object

          object = options[prep]
        end
      end
      object
    end
  end
end

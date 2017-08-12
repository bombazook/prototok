
module Prototok
  module Serializers
    class Token < Base
      attributes :exp, :nbf, :iat, serializer: :time, nil: :delete, empty: :delete
      attributes :payload, :jti
    end
  end
end

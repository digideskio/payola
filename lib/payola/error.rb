require 'human_error/error'

module  Payola
class   Error < RuntimeError
  include HumanError::Error
end
end

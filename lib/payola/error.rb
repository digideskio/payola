require 'human_error/error'

module  Payola
class   Error < RuntimeError
  extend HumanError::Error
end
end

class Rejection < ApplicationRecord
  belongs_to :sample
  belongs_to :rejection_reason
end

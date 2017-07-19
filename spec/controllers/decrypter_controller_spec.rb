require 'rails_helper'

RSpec.describe DecrypterController, type: :controller do

  describe "GET #decrypt" do
    it "returns http success" do
      get :decrypt
      expect(response).to have_http_status(:success)
    end
  end

end

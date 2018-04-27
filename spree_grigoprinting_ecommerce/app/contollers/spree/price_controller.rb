module Spree
  class PriceController < Spree::StoreController
    before_action :converti_more_options


    def calcola_bandiera
      prezzo = Spree::CalcolatorePrezzo.calcola_bandiera(params)
      # genera consegne
      @consegna = Spree::CalcolatoreConsegna.calcola_bandiera(prezzo)

      respond_to do |format|
        format.js{}  #this will make rails look for a file named calculate_flag.js.erb in your views
      end
    end

    private

    def converti_more_options
      params[:more_options] = JSON.parse(params[:more_options], symbolize_names: true)
    end
  end
end

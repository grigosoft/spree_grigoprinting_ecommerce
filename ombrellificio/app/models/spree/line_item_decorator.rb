module Spree
  LineItem.class_eval do
    has_many :upload, class_name: 'Spree::Upload'

    belongs_to :padre, class_name: 'Spree::LineItem'
    has_many :figli, class_name: 'Spree::LineItem', foreign_key: 'padre_id', dependent: :destroy

    delegate :personalizzabile, to: :variant

    def update_price
      # lo cambio dentro VARIANT se personalizzato
      if more_options
        more_opt_h = JSON.parse(more_options, symbolize_names: true)
        # calcolo nuovo prezzo se non salvato (prodotto nel carrello)
        if more_opt_h[:prezzo].nil? && !more_opt_h[:consegna].nil?
          # aggiungo nei parametri la quantita per il ricalcolo del prezzo
          more_opt_h[:quantity] = quantity
          if more_opt_h[:prodotto_personalizzato] == 'bandiera_personalizzata'
            prezzo = Spree::CalcolatorePrezzo.calcola_bandiera(more_opt_h)
            variant.price = Spree::CalcolatoreConsegna.calcola_bandiera(prezzo)[more_opt_h[:consegna].to_i][:prezzo]
          end
        elsif !more_opt_h[:prezzo].nil? # forse non necessario, non dovrebbe mai richiamare questo metodo dopo che l'ordine ha fatto il ceckout!
          variant.price = more_opt_h[:prezzo]
        end
      end

      self.price = variant.price_including_vat_for(tax_zone: tax_zone)
    end

    def description
      desc = variant.description
      if more_options
        more_opt_h = JSON.parse(more_options, symbolize_names: true)
        if more_opt_h[:prodotto_personalizzato] == 'bandiera_personalizzata'
          desc = 'in <b>%{tessuto}</b> cm<b>%{base}x%{altezza}</b>, %{orientamento},\n' %
                 more_opt_h

          prezzo = Spree::CalcolatorePrezzo.calcola_bandiera(more_opt_h)
          cosnsegna = Spree::CalcolatoreConsegna.calcola_bandiera(prezzo)[more_opt_h[:consegna].to_i]

          desc += '\nNome lavoro: <b>%{nome}</b>\nConsegna prevista <b>%{g} %{n} %{m}</b>' % { g: cosnsegna[:giorno],
                                                         n: cosnsegna[:numero],
                                                         m: cosnsegna[:mese],
                                                         nome: more_opt_h[:nome]}
        end
      end
      desc.gsub('\n', '</br>')
    end

    def stato
      return 0 if order.canceled?
      stat = -1
      stat = 1 if order.completed?
      stat = 2 if product.personalizzabile? && stato_files == 'da_approvare'
      stat = 3 if !product.personalizzabile? || stato_files == 'approvato'
      stat = 4 if !product.personalizzabile? || stato_files == 'approvato' && true # aggiungere 2 ore di wait
      stat = 5 if stato_spedizione == 'spedito'
      stat = 6 if stato_spedizione == 'consegnato'

      stat
    end

    def stato_display
      case stato
      when 1
        %w[Confermato warning]
      when 2
        ['File Caricato', 'warning']
      when 3
        %w[Approvazione warning]
      when 4
        ['In lavorazione', 'warning']
      when 5
        %w[Spedito success]
      when 6
        %w[Consegnato success]
      when 0
        %w[Annullato allert]
      else
        %w[Errore allert]
      end
    end

    def add_storico_files(azione="", info="")
      new_row = {}
      new_row[:azione] = azione
      new_row[:info] = info
      new_row[:timestamp] = Time.now
      storico = storico_files_decoded
      if !storico.nil?
        storico.push(new_row)
      else
        storico = [new_row]
      end
      self.storico_files = storico.to_json
      save!
    end

    def stato_files
      storico = storico_files_decoded
      return 'approvato' if !storico.nil? && storico.last[:azione] == 'approvato'
      return 'disapprovato' if !storico.nil? && storico.last[:azione] == 'disapprovato'
      'da_approvare'
    end

    def file_approvati?
      storico = storico_files_decoded
      return true if !storico.nil? && storico.last[:azione] == 'approvato'
      false
    end

    def more_options_hash
      return JSON.parse(more_options, symbolize_names: true) unless more_options.nil?
      nil
    end
    # private

    def storico_files_decoded
      return JSON.parse(storico_files, symbolize_names: true) unless storico_files.nil?
      nil
    end

  end
end

function se_toMoreOptions(){
  prodotto.moreOptions["extra"] = {};
  if($("input#vettorializzazione_accepted").prop( "checked" )) {
    prodotto.moreOptions["extra"]['grafica'] = $("input#vettorializzazione_accepted").attr('variant_id');
  } else if($("input#impaginazione_accepted").prop( "checked" )) {
    prodotto.moreOptions["extra"]['grafica'] = $("input#impaginazione_accepted").attr('variant_id');
  } else if($("input#controllo_file_accepted").prop( "checked" )) {
    prodotto.moreOptions["extra"]['grafica'] = $("input#controllo_file_accepted").attr('variant_id');
  }
}
function se_fromMoreOptions(){
  if(prodotto.moreOptions["extra"] != null && prodotto.moreOptions["extra"]['grafica'] != null){
    if(prodotto.moreOptions["extra"]['grafica'] == $("input#vettorializzazione_accepted").attr('variant_id')){
      $("input#vettorializzazione_accepted").prop( "checked", true )
      $("input#impaginazione_accepted").prop( "checked", true )
      $("input#controllo_file_accepted").prop( "checked", true )
    } else if(prodotto.moreOptions["extra"]['grafica'] == $("input#impaginazione_accepted").attr('variant_id')){
      $("input#vettorializzazione_accepted").prop( "checked", false )
      $("input#impaginazione_accepted").prop( "checked", true )
      $("input#controllo_file_accepted").prop( "checked", true )
    } else if(prodotto.moreOptions["extra"]['grafica'] == $("input#controllo_file_accepted").attr('variant_id')){
      $("input#vettorializzazione_accepted").prop( "checked", false )
      $("input#impaginazione_accepted").prop( "checked", false )
      $("input#controllo_file_accepted").prop( "checked", true )
    } else {
      $("input#vettorializzazione_accepted").prop( "checked", false )
      $("input#impaginazione_accepted").prop( "checked", false )
      $("input#controllo_file_accepted").prop( "checked", false )
    }
  } else {
    $("input#vettorializzazione_accepted").prop( "checked", false )
    $("input#impaginazione_accepted").prop( "checked", false )
    $("input#controllo_file_accepted").prop( "checked", false )
  }
}
function se_prezzo(){
  var tot = 0;
  var soggetti = $('#soggetti').val();
  if($("input#controllo_file_accepted").prop( "checked" )) {
    tot += parseFloat($("input#controllo_file_accepted").attr('prezzo'));
  }
  if($("input#impaginazione_accepted").prop( "checked" )) {
    tot += parseFloat($("input#impaginazione_accepted").attr('prezzo'));
  }
  if($("input#vettorializzazione_accepted").prop( "checked" )) {
    tot += parseFloat($("input#vettorializzazione_accepted").attr('prezzo'));
  }
  return tot*soggetti;
}
$(document).ready(function(){
  $(document).on("click", "input#controllo_file_accepted", selezionaExtra);
  $(document).on("click", "input#impaginazione_accepted", selezionaExtra);
  $(document).on("click", "input#vettorializzazione_accepted", selezionaExtra);

  prodotto.toMoreOptions.push(se_toMoreOptions);
  prodotto.fromMoreOptions.push(se_fromMoreOptions);
  prodotto.prezzo.push(se_prezzo);
  prodotto.visualizza.push(function(){
    $('#lbl_soggeti_in_extra').html(' x'+$('#soggetti').val());
  });
});

// funzioni vi visibilita
function selezionaExtra(){
  var $this = $(this);
  if($this.is("input#vettorializzazione_accepted") && $("input#vettorializzazione_accepted").prop( "checked" )) {
    $("input#vettorializzazione_accepted").prop( "checked", true );
    $("input#impaginazione_accepted").prop( "checked", true );
    $("input#controllo_file_accepted").prop( "checked", true );
  } else if($this.is("input#impaginazione_accepted") && $("input#impaginazione_accepted").prop( "checked" )) {
    $("input#vettorializzazione_accepted").prop( "checked", false );
    $("input#impaginazione_accepted").prop( "checked", true );
    $("input#controllo_file_accepted").prop( "checked", true );
  } else if($this.is("input#controllo_file_accepted") && $("input#controllo_file_accepted").prop( "checked" )) {
    $("input#vettorializzazione_accepted").prop( "checked", false );
    $("input#impaginazione_accepted").prop( "checked", false );
    $("input#controllo_file_accepted").prop( "checked", true );
  } else {
    $("input#vettorializzazione_accepted").prop( "checked", false );
    $("input#impaginazione_accepted").prop( "checked", false );
    $("input#controllo_file_accepted").prop( "checked", false );
  }
  prodotto.fireToMoreOptions();
}

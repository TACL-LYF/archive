jQuery(function ($) {
  $("#other_amount").change(function(){
    if($(this).val()){
      $("#other_option").prop("checked", true);
      $("label.btn").removeClass("active");
      $("#other_option").val($(this).val());
    } else {
      $("#other_option").prop("checked", false);
    }
  });

  $("#company").change(function(){
    if($(this).val()){
      $("#company_match").prop("checked", true);
    } else {
      $("#company_match").prop("checked", false);
    }
  });

  var show_error, stripeResponseHandler;
  $("#donation_form").submit(function (event) {
    var $form;
    $form = $(this);
    $form.find("input[type=submit]").prop("disabled", true);
    Stripe.card.createToken($form, stripeResponseHandler);
    return false;
  });

  stripeResponseHandler = function (status, response) {
    var $form, token;
    $form = $("#donation_form");
    if (response.error) {
      $(".stripe_error").text("Error: " + response.error.message);
      $form.find("input[type=submit]").prop("disabled", false);
    } else {
      token = response.id;
      card = response.card;
      if (card.brand == "American Express") {
        $(".stripe_error").text("Sorry, we do not accept American Express");
        $form.find("input[type=submit]").prop("disabled", false);
      } else {
        $("#donation_stripe_card_token").val(token);
        $("[data-stripe=number]").val('');
        $("[data-stripe=cvc]").val('');
        $("[data-stripe=exp_year]").val('');
        $("[data-stripe=exp_month]").val('');
        $form.get(0).submit();
      }
    }
    return false;
  };
});

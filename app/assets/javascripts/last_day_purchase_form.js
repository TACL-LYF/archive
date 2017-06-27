jQuery(function ($) {
  var dollarfordollar_checkbox = $("#dollar_for_dollar");
  var company_field = $("#company");

  company_field.focus(function(){
    dollarfordollar_checkbox.prop("checked", true);
  });

  company_field.blur(function(){
    if(!$(this).val()){
      dollarfordollar_checkbox.prop("checked", false);
    }
  })

  var show_error, stripeResponseHandler;
  $("#last_day_purchase_form").submit(function (event) {
    var $form;
    $form = $(this);
    $form.find("input[type=submit]").prop("disabled", true);
    Stripe.card.createToken($form, stripeResponseHandler);
    return false;
  });

  stripeResponseHandler = function (status, response) {
    var $form, token;
    $form = $("#last_day_purchase_form");
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
        $("#last_day_purchase_stripe_token").val(token);
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

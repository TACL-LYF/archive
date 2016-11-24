jQuery(function ($) {
  var show_error, stripeResponseHandler;
  $("#registration_form").submit(function (event) {
    var $form;
    $form = $(this);
    $form.find("input[type=submit]").prop("disabled", true);
    Stripe.card.createToken($form, stripeResponseHandler);
    return false;
  });

  stripeResponseHandler = function (status, response) {
    var $form, token;
    $form = $("#registration_form");
    if (response.error) {
      $(".stripe_error").text("Error: " + response.error.message);
      $form.find("input[type=submit]").prop("disabled", false);
    } else {
      token = response.id;
      $("#wizard_stripe_card_token").val(token);
      $("[data-stripe=number]").remove();
      $("[data-stripe=cvc]").remove();
      $("[data-stripe=exp_year]").remove();
      $("[data-stripe=exp_month]").remove();
      $("[data-stripe=address_zip]").remove();
      $form.get(0).submit();
    }
    return false;
  };
});

jQuery(function ($) {
  $("input[type=radio]:checked").parent(".btn").addClass("active")

  var other_option_radio = $("#other_option");
  var other_amount_field = $("#other_amount");
  var company_checkbox = $("#company_match");
  var company_field = $("#company");


  other_amount_field.focus(function(){
    other_option_radio.prop("checked", true).change();
  });
  other_amount_field.blur(function(){
    if(!$(this).val()) {
      other_option_radio.prop("checked", false);
    }
  })

  other_amount_field.change(function(){
    if($(this).val()){
      other_option_radio.val($(this).val());
    } else {
      other_option_radio.prop("checked", false);
    }
  });

  other_option_radio.change(function(){
    if($(this).is(':checked')){
      $("label.btn").removeClass("active");
    }
  });

  company_field.focus(function(){
    company_checkbox.prop("checked", true);
  });

  company_field.blur(function(){
    if(!$(this).val()){
      company_checkbox.prop("checked", false);
    }
  })

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
        $("#donation_stripe_token").val(token);
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

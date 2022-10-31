var stripe;
var card;
var elements;


window.addEventListener('load', loadStripeNew);


function paymentFinished() {
    $("#spinner").hide();
    $(".form-input-required").attr("visited",true);
    updateHighlights(undefined);
}

function updateHighlights(event) {
    
    $(".form-input-required").removeClass("invalid");

    var validForm = true;
    
    for (var i of $(".form-input-required")) {
        
        if(i.type == "checkbox" && i.checked == false) {
            validForm = false;
        }
        if (i.value == ''){
            
            validForm = false;

            if(i.hasAttribute('visited')) {
                i.classList.add('invalid');
            }
            
        }
    }
 
    if (validForm) {
        document.getElementById('submitButton').removeAttribute('disabled');
    } else {
        document.getElementById('submitButton').setAttribute('disabled',true);
    }
}

function clickField(event) {
    event.target.setAttribute("visited", true);
}

function blurField(event) {
    updateHighlights(undefined);
}

function handleTypeChange() {
    $("#spinner").show();
    handlePriceChange();
}

function priceChangeComplete() {
    $("#spinner").hide();
}

function loadStripeNew() {
    console.log('hit new stripe')
    stripe = Stripe(apiKey);
    elements = stripe.elements();
    var elements = stripe.elements({
        fonts: [
          {
            cssSrc: 'https://fonts.googleapis.com/css?family=Quicksand',
          },
        ],
        // Stripe's examples are localized to specific languages, but if
        // you wish to have Elements automatically detect your user's locale,
        // use `locale: 'auto'` instead.
        locale: window.__exampleLocale,
      });
    
    var elementStyles = {
        
        base: {
                
            fontFamily: 'Avenir',
            fontSmoothing: 'antialiased',
            fontSize: '18px',
            color: '#000000',
            '::placeholder': {
                color: '#000000',
            }
        },
        invalid: {
            color: '#fa755a',
            iconColor: '#fa755a'
        }
      };
    
      var elementClasses = {
        focus: 'focus',
        empty: 'empty',
        invalid: 'invalid',
      };
    
      var cardNumber = elements.create('cardNumber', {
        style: elementStyles,
        classes: elementClasses,
      });
      cardNumber.mount('#cardNumber');
    
      var cardExpiry = elements.create('cardExpiry', {
        style: elementStyles,
        classes: elementClasses,
      });
      cardExpiry.mount('#cardExpiry');
    
      var cardCvc = elements.create('cardCvc', {
        style: elementStyles,
        classes: elementClasses,
      });
      cardCvc.mount('#cardCvc');

      cardNumber.addEventListener('change', function (event) {
        var displayError = document.getElementById('card-errors');
        if (event.error) {
            displayError.classList.add("alert");
            displayError.textContent = event.error.message;
        } else {
            if (displayError.classList.contains("alert")) {
                displayError.classList.remove("alert");
            }
          
            displayError.textContent = '';
        }
    });
      cardExpiry.addEventListener('change', function (event) {
        var displayError = document.getElementById('card-errors');
        if (event.error) {
            displayError.classList.add("alert");
            displayError.textContent = event.error.message;
        } else {
            if (displayError.classList.contains("alert")) {
                displayError.classList.remove("alert");
            }
            displayError.textContent = '';
        }
      });
    cardCvc.addEventListener('change', function (event) {
      var displayError = document.getElementById('card-errors');
      if (event.error) {
        displayError.classList.add("alert");  
        displayError.textContent = event.error.message;
      } else {
          if (displayError.classList.contains("alert")) {
              displayError.classList.remove("alert");
          }
          displayError.textContent = '';
      }
    });

    var form = document.getElementById(formId);
    form.addEventListener('submit', function (event) {
        event.preventDefault();

        $("#spinner").show();

        stripe.createToken(cardNumber).then(function (result) {
            if (result.error) {
                // Inform the customer that there was an error.
                var errorElement = document.getElementById('card-errors');
                errorElement.textContent = result.error.message;
                $("#spinner").hide();
            } else {
                // Send the token to the server.
                handleStripeToken(result.token.id);
            }
        });
    });


    
    //   registerElements([cardNumber, cardExpiry, cardCvc], 'example3');
}

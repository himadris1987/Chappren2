var stripe;
var card;
var elements;

window.addEventListener('load', function() {
    var form = document.getElementById(formId);
    form.addEventListener('submit', function(event) {
        event.preventDefault();

        $("#spinner").show();

        console.log("Submit clicked.");
        
        stripe.createToken(card).then(function(result) {
            console.log("Token Received.");
            if (result.error) {
                // Inform the customer that there was an error.
                var errorElement = document.getElementById('card-errors');
                errorElement.textContent = result.error.message;
                $("#spinner").hide();
                console.log("Displaying Error.");
            } else {
                // Send the token to the server.
                console.log("Sending token to back-end.")
                handleStripeToken(result.token.id);
                
            }

            console.log("Done.");
        });
    });
});

function  createStripe() {
    stripe = Stripe(apiKey); 
    elements = stripe.elements();
    
    var style = {
        base: {
            color: '#000000',
            fontFamily: '"Lexend", sans-serif',
            // fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
            fontSmoothing: 'antialiased',
            fontSize: '18px',
            fontWeight: 'bold',
            '::placeholder': {
                color: '#000000'
            }
        },
        invalid: {
            color: '#fa755a',
            iconColor: '#fa755a'
        }
    };
    
    card = elements.create('card', {style: style});
    
    card.mount("#card-element");
    
    card.addEventListener('change', function(event) {
        var displayError = document.getElementById('card-errors');
        if (event.error) {
            displayError.textContent = event.error.message;
        } else {
            displayError.textContent = '';
        }
    });

    
}

function paymentFinished() {
    $("#spinner").hide();
    $(".form-input-required").attr("visited",true);
    updateHighlights(undefined);
}

function updateHighlights(event) {

    $(".form-input-required").removeClass("invalid");

    var validForm = true;

    for (var i of $(".form-input-required")) {
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
window.addEventListener('load', function() {
   

    var form = document.getElementById(formId);
    form.addEventListener('submit', function(event) {
        event.preventDefault();

        $("#spinner").show();

        var errorElement = document.getElementById('errors');
        errorElement.textContent = result.error.message;
        $("#spinner").hide();

    });
    
});

// form.addEventListener('submitButton', function(event) {
//     event.preventDefault();
    
//     $("#spinner").show();
// });
function submit(){

}
function finished() {
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
        if (i.classList.contains('email-box')) {
            if(i.value.includes('@') == false || i.value.includes('.') == false ) {
                if(i.hasAttribute('visited')) {
                    i.classList.add('invalid');
                }
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

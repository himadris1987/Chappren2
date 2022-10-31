$(document).ready(function(){
    console.log('test');
    $('[type="date"]').prop('min', function(){
        return new Date().toJSON().split('T')[0];
    });
});

function formChange() {
    $("#spinner").show();

    rerenderForm();
    
}


function pageRerendered() {
    $("#spinner").hide();
}

var pattern = /[a-zA-Z0-9._\-\+]+@[a-zA-Z0-9._-]+\.[a-zA-Z]{2,4}/;



function submitForm() {
    var selectedTs = $("input[name='timeslot']:checked").val();
    var email = $("input[element='email']").val();
    var duration = $("select[element='duration'] > option[selected='selected']").val();
    
    if (!duration) {
        duration = "180"; //Assume it's a podcast booth.
    }


    if (validate()) {
        $("#spinner").show();
        console.log("Valid Input. Going to Server.")

        console.log('Selected Time Slot: ' + selectedTs);
        console.log('Email: '+email);
        console.log('Duration: '+duration);
        
        Visualforce.remoting.Manager.invokeAction(
            submitFormRemoteFunction,
            selectedTs,
            email,
            duration,
            function(result, event){
                if (event.status) {
                    // Get DOM IDs for HTML and Visualforce elements like this
                    console.log("Remote action: Success.");
                    var redirect = decodeURIComponent(result);

                   console.log(event);
                   console.log(redirect);
                   window.location.assign(redirect.replace(/&amp;/g, "&"));
                } else if (event.type === 'exception') {
                    console.log("Remote action: Exception.");
                    console.log(event);
                } else {
                    console.log("Remote Action: Something else happened.");
                    console.log(event);
                }
            }, 
            {escape: true}
        );
        console.log("Sending Remote Action");
    }
}

function validate() {
    var valid = true;

    var enteredEmail = $('input[type="email"]').val();
    if (!pattern.test(enteredEmail)) {
        $('#invalidEmailAddress').show();
        valid = false;
    } else {
        $('#invalidEmailAddress').hide();
    }


    var selectedTs = $("input[name='timeslot']:checked").val();
    if (selectedTs) {
        $('#invalidTime').hide();
    } else {
        $('#invalidTime').show();
        valid = false;
    }
    return valid;
}
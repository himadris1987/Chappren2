let formbutton = document.getElementById('j_id0:apexForm:formButton');
let pageMessage = document.getElementById('j_id0:apexForm:pageMessage');
let myForm = document.getElementById('j_id0:apexForm:apexForm');
let firstName = document.getElementById('j_id0:apexForm:firstName');
let lastName = document.getElementById('j_id0:apexForm:lastName');
let email = document.getElementById('j_id0:apexForm:emailBox');
let phoneNumber = document.getElementById('j_id0:apexForm:phoneNumber');
let company = document.getElementById('j_id0:apexForm:companyBox');

formbutton.addEventListener('click', delayFunction());

function delayFunction() {
    setTimeout(clearForm(), 0);
}

function clearForm() {
    if(firstName.value && lastName.value && email.value.includes('@') && phoneNumber.value) {  
        firstName.value = '';
        lastName.value = '';
        email.value = '';
        phoneNumber.value = '';
        company.value = '';
        // console.log('hi')
        // myForm.reset();
        let successMessage = document.createElement('div');
        successMessage.className = 'alert alert-success weblead_my_alert';
        successMessage.setAttribute('role', 'alert');
        successMessage.innerText = "Thank you";
        pageMessage.appendChild(successMessage);
        setTimeout(function () {pageMessage.removeChild(successMessage)}, 1000);
        // window.location.href = 'https://hashtagfresno.com/';
    } 
}
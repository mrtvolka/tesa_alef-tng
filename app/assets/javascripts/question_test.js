function getConfirmation(){

    var form = document.getElementById('test-form');
    var questions = document.getElementsByClassName('my-mobile-content');
    var textareas = document.getElementsByTagName('textarea');
    var count = 0;

    for(var x = 0; x < questions.length; x++){
        var is_checked = false;
        var inputs = questions[x].getElementsByTagName('input');
        var y = 0;

        while(y!=inputs.length && is_checked==false) {
            if (inputs[y].type == 'checkbox' || inputs[y].type == 'radio') {
                is_checked = inputs[y].checked;
            }
            y += 1;
        }
        if(is_checked==true) count += 1;
    }

    for(var z=0 ; z < textareas.length; z++){
        console.log(textareas[z].value)
        if(textareas[z].value != '') count += 1;
    }

    if (count != questions.length) {
        var retVal = confirm("Nevyplnil si všetky otázky. Chceš aj napriek tomu odovzdať test?");
        if (retVal == true) {
            document.getElementById("clickButton").click();
            return true;
        }
        else {
            return false;
        }
    }else {
        document.getElementById("clickButton").click();
        return true;
    }

}
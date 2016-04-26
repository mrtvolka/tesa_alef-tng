var clickButton = document.getElementById("clickButton");

function getConfirmation(){

    var form = document.getElementById('test-form');
    var questions = document.getElementsByClassName('my-mobile-content');
    var textareas = document.getElementsByTagName('textarea');
    var eval = document.getElementsByClassName('eval');
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
        if(textareas[z].value != '') count += 1;
    }

    for(var z=0 ; z < eval.length; z++){
        count += 1;
    }

    clickButton = document.getElementById("clickButton");
    if (count != questions.length) {
        el = document.getElementById("modal");
        //el.style.top = (el.style.top == "50%") ? "-50%" : "50%";
        el.style.opacity = (el.style.opacity == "1") ? "0" : "1";
        el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
    }else {
        clickButton.click();
        return true;
    }

}

function clickYes(){
    clickButton.click();
}

function hide(){
    el = document.getElementById("modal");
    el.style.visibility = (el.style.visibility == "hidden") ? "visible" : "hidden";
    //el.style.top = (el.style.top == "-50%") ? "50%" : "-50%";
    el.style.opacity = (el.style.opacity == "0") ? "1" : "0";
}

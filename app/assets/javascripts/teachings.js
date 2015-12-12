$(function() {
    $('.show_hidden').click(function(event){
        var elements = document.getElementsByClassName("hiddenBlock");
        var trigger= event.target;
        var inter_from= Number(trigger.name.split(',')[0]);
        var inter_to=   Number(trigger.name.split(',')[1]);
        for(var i=0; i<elements.length; i++) {
            if(Number(elements[i].id) >= inter_from && Number(elements[i].id) <= inter_to) {
                if (elements[i].style.display == 'none') {
                    elements[i].style.display = '';
                } else {
                    elements[i].style.display = 'none';
                }
            }
        }

    });
});

$(document).ready(
    function(event) {
        var elements = document.getElementsByClassName("hiddenBlock");
        var triggers = document.getElementsByClassName("show_hidden");
        for (var j = 0; j < triggers.length; j++){
            var inter_from = Number(triggers[j].name.split(',')[0]);
            var inter_to = Number(triggers[j].name.split(',')[1]);
            for (var i = 0; i < elements.length; i++) {
                if (Number(elements[i].id) >= inter_from && Number(elements[i].id) <= inter_to) {
                    if (elements[i].style.display == 'none') {
                        elements[i].style.display = '';
                    } else {
                        elements[i].style.display = 'none';
                    }
                }
            }
        }
    })
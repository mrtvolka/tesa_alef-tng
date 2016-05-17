var TestSliders= {

    slider : new Array(),
    input_name : new Array(),


    setupTestEvaluatorSlider : function() {
        this.slider = $('.Axd')

        for (index = 0; index < this.slider.length; ++index) {
            $(this.slider[index]).slider({
                animate: 'fast',
                max: 100,
                min: 0,
                orientation: 'horizontal',
                range: "min",
                value: 50,

                change: function(event, ui) {
                    var value = ui.value;
                    var answerInput = $(event.target).siblings('input');
                    answerInput.val(value);
                }
            });
        }
    }
}
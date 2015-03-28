var Question = {

    type : null,

    isSingleChoice : function() { return this.type == "singlechoicequestion"; },
    isMultiChoice : function() { return this.type == "multichoicequestion"; },
    isEvaluator : function() { return this.type == "evaluatorquestion"; },

    setupForm : function() {

        // nastavi typ otazky
        var formId = $('.question-form').attr('id');
        this.type = (/form-(.*)/.exec(formId))[1];

        // nastavi formular
        $('.question-evaluations').hide();
        $('.answer-input').prop('disabled',false);

        // pripad ked prezerame odpovede
        if(gon.show_solutions) {
            this.disableForm();
            this.showSolution(gon.solution);
        }
    },

    disableForm : function() {
        // Upravi moznosti pod otazkou a vypne formulare

        if (this.isEvaluator()) {
            $('#evaluator-slider').slider("disable");
            $('#evaluator-slider').css('opacity',1);
        }
        if (this.isSingleChoice() || this.isMultiChoice()) {
            $('.answer-input').prop('disabled',true);
        }
        $('.question-button').hide();
    },

    evaluateAnswers : function(solution) {

        if (this.isEvaluator()) {
            this.evaluateEvaluatorQuestion(solution);
        }
        if (this.isSingleChoice() || this.isMultiChoice()) {
            this.evaluateChoiceQuestion(solution);
        }
        $('#question-evaluation-next').show();
    },

    evaluateEvaluatorQuestion : function(solution) {

        if(solution == undefined) {
            this.setMessage("gratulujeme, ako prvý ste odpovedali na túto otázku");
            return;
        }

        Slider.evaluateAnswer(solution);
        this.setMessage("bol zobrazený priemer odpovedí");

        $('#question-evaluation-next').show();
    },

    evaluateChoiceQuestion : function(solution) {

        var isSolutionCorrect = true;

        $('.answer-input').each(function() {
            var isChecked = $(this).is(':checked');
            var inputValue = parseInt($(this).val());
            var isRight = $.inArray(inputValue, solution) != -1;

            if(isChecked == isRight) {
                $(this).addClass('answer-is-correct');
            } else {
                $(this).addClass('answer-is-incorrect');
                isSolutionCorrect = false;
            }
        });

        if(isSolutionCorrect) {
            this.setMessage("správna odpoveď");
        } else {
            this.setMessage("nesprávna odpoveď");
        }

    },

    showSolution : function(solution) {

        if (this.isEvaluator()) {
            this.showEvaluatorSolution(solution);
        }
        if (this.isSingleChoice() || this.isMultiChoice()) {
            this.showChoiceSolution(solution);
        }

        $('#question-evaluation-next').show();
    },

    showEvaluatorSolution : function(solution) {


        if(solution == undefined) {
            this.setMessage("bohužiaľ, k tejto otázke zatiaľ nemáme odpovede");
            return;
        }

        Slider.showSolution(solution);
        this.setMessage("bol zobrazený priemer odpovedí");

        $('#question-evaluation-next').show();
    },

    showChoiceSolution : function(solution) {
        $('.answer-input').each(function() {
            var inputValue = parseInt($(this).val());
            var isRight = $.inArray(inputValue, solution) != -1;

            if(isRight) {
                $(this).prop( "checked", true );
            } else {
                $(this).prop( "checked", false );
            }

        });

        this.setMessage("bola zobrazená správna odpoveď");
    },

    setMessage : function(message) {

        $('#question-evaluation-message').html(message).show();

    }
};
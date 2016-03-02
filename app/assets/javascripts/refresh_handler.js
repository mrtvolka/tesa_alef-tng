var Refresh = {
    init: function () {
        var myId = null;

        $(document).ready(function () {
            myId = setInterval(refreshPartial, 1000)
        });

// calls action refreshing the partial
        function refreshPartial() {
            if ($('#counter' + gon.exercise_id).length) {
                $.ajax({
                    url: "event/refresh",
                    data: {id: gon.exercise_id},
                        });
                        } else {
                        clearInterval(myId);
                    }
            }
    }
}

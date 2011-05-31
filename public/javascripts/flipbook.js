$(document).ready(function() {

    var $pid = $('.document_viewer').attr('id');
    $.get('/assets/' + $pid ,
    function(data) {
        $(data).appendTo('#embedded_viewer');
        $("#embedded_viewer").fadeIn("slow");
    });
});
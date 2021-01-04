$(document).ready(function() {
    window.addEventListener('message', function(event) {
        if (event.data.action == 'setVisible') {
            if (event.data.value) {
                $('body').fadeIn();
                $('.main').fadeIn();
            }
            else {
                $('body').fadeOut();
                $('.main').fadeOut();
            }
        }
    });
});

$('#exit').on('click', function(event) {
    $.post('https://cui_wardrobe/close', JSON.stringify({
    }));
});
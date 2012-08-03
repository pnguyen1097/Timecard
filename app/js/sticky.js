$(document).ready(function() {

    stickyTop = new Array();

    $('.sticky').each(function() {
        stickyTop.push($('.sticky').offset().top);
    });

    $(window).scroll(function() {

        for (i = 0; i < stickyTop.length; i++) {
            if ($(window).scrollTop() >= stickyTop[i]) {
                $('.sticky').eq(i).css({
                    position:'fixed',
                    top: 0,
                });
                $('.sticky').eq(i).parent().css('padding-top', $('.sticky').eq(i).height());
                console.log($('.sticky').height());
            } else {
                $('.sticky').eq(i).css({
                    position : 'static',
                });
                $('.sticky').eq(i).parent().css('padding-top', '');
            }
        }
    });
});

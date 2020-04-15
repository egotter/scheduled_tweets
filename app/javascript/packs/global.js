$(function () {
  // Switch background color for navbar
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover();

  $(".popover-dismiss").popover({
    trigger: "focus"
  });

  var navbarCollapse = function () {
    if ($(".navbar.fixed-top").length === 0) {
      return;
    }
    if ($(".navbar.fixed-top").offset().top > 0) {
      $(".navbar").addClass("navbar-scrolled");
    } else {
      $(".navbar").removeClass("navbar-scrolled");
    }
  };
  navbarCollapse();
  $(window).scroll(navbarCollapse);

  // Smooth scrolling when clicking an anchor link
  $('a[href^="#"]').click(function () {
    if ($(this).attr('href') === '#') {
      return;
    }

    if ($(this).data('toggle') === 'collapse') {
      return;
    }

    $('html, body').animate({
      scrollTop: $($(this).attr('href')).offset().top
    }, 500);
    return false;
  });
});

class SnackMessage {
  constructor() {
  }

  static show(message) {
    var options = {
      actionText: '&times;',
      actionTextColor: '#777',
      backgroundColor: '#eee',
      pos: 'top-center',
      duration: 7500,
      text: message
    };
    Snackbar.show(options);
  }
}

window.SnackMessage = SnackMessage;

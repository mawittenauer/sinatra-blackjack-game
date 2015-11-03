$(document).ready(function() {
  player_hit();
  player_stay();
  dealer_hit();
});

function player_hit() {
  $(document).on('click', 'form#hit_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/player_hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
};

function player_stay() {
  $(document).on('click', 'form#stay_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/player_stay'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
};

function dealer_hit() {
  $(document).on('click', 'form#dealer_hit_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/dealer_hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
};

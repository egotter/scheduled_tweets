class InputArea {
  constructor() {
    var $el = $('#input-text');
    var self = this;
    this.remainingMax = 280;

    $el.autosize();

    $el.on('keyup', function () {
      var $preview = $('#live-preview .tweet-preview');

      var previous = $el.data('previous');
      var current = $el.val();

      if (previous !== current) {
        console.log('input', current);
        self.setRemainingCount(self.remainingMax - self.countChars(current));

        var str = self.escapeTags(current).replace(/(?:\r\n|\r|\n)/g, '<br>');
        console.log('converted', str);

        $preview.html(str);
        $el.data('previous', current);
        $('.tweet-text')[0].value = current;
      }
    });
  }

  setRemainingCount(count) {
    $('.remaining-count').text(count);
  }

  escapeTags(text) {
    var chars = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;'
    };

    function replace(c) {
      return chars[c] || c;
    }

    return text.replace(/[&<>]/g, replace);
  }

  countChars(str) {
    var len = 0;
    str = str.split("");

    for (var i = 0; i < str.length; i++) {
      if (str[i].match(/[ｦ-ﾟ]+/)) {
        len++;
      } else {
        if (escape(str[i]).match(/^\%u/)) {
          len += 2;
        } else {
          len++;
        }
      }
    }

    return len;
  }
}

window.InputArea = InputArea;

class DatePicker {
  constructor({maxDate = null} = {}) {
    flatpickr('#date-picker', {
      minDate: 'today',
      maxDate: maxDate,
      allowInput: true
    });
  }
}

window.DatePicker = DatePicker;

class TimePicker {
  constructor() {
    $('#time-picker').timepicker({
      'scrollDefault': 'now',
      'minTime': '0:00',
      'maxTime': '23:59',
      'step': 5
    });
  }
}

window.TimePicker = TimePicker;

class ImagePreview {
  constructor(fileUploader) {
    $('#live-preview .preview-image-container').on('close.bs.alert', function (e) {
      $(this).hide();
      fileUploader.clear();
      $('#live-preview .preview-image').attr('src', null);
      return false;
    });
  }
}

window.ImagePreview = ImagePreview;

class FileUploader {
  constructor() {
    var $el = this.$el = $('#input-image');
    var self = this;

    $('.upload-file').on('click', function () {
      $el.trigger('click');
    });

    $el.change(function () {
      self.readURL(this);
    });
  }

  clear() {
    this.$el[0].value = '';
  }

  readURL(input) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();

      reader.onload = function (e) {
        $('#live-preview .preview-image').attr('src', e.target.result);
        $('#live-preview .preview-image-container').show();
      };

      reader.readAsDataURL(input.files[0]);
    }
  }
}

window.FileUploader = FileUploader;

class AlertMessage {
  constructor(selector) {
    var $el = this.$el = $(selector);
    $el.on('close.bs.alert', function (e) {
      $el.parent().hide();
      return false;
    });
  }

  show(message) {
    console.log('show', message);
    this.$el.find('.message').text(message);
    this.$el.parent().show();
  }

  hide() {
    this.$el.find('.message').text('');
    this.$el.parent().hide();
  }
}

window.AlertMessage = AlertMessage;

class AttributeLabels {
  constructor() {
    this.labels = [
      $('.text-label'),
      $('.specified_date-label'),
      $('.specified_time-label')
    ];

    this.color = this.labels[0].css('color');
  }

  clear() {
    for (var $label of this.labels) {
      $label.css('color', this.color);
    }
  }
}

window.AttributeLabels = AttributeLabels;

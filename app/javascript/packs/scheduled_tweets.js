class Util {
  static escapeTags(text) {
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

  static countChars(str) {
    var len = 0;
    str = str.split("");

    for (var i = 0; i < str.length; i++) {
      if (str[i].match(/[ｦ-ﾟ]+/)) {
        len++;
      } else {
        if (escape(str[i]).match(/^%u/)) {
          len += 2;
        } else {
          len++;
        }
      }
    }

    return len;
  }
}

class ImagePreview {
  constructor() {
    this.callback = null;
    var self = this;

    $('#live-preview .preview-image-container').on('close.bs.alert', function () {
      $(this).hide();
      $('#live-preview .preview-image').attr('src', null);

      if (self.callback) {
        self.callback();
      }
      return false;
    });
  }

  on(type, fn) {
    if (type === 'close') {
      this.callback = fn;
    }
  }
}

class Form {
  constructor() {
    this.$el = $('#form');
    this.$submit = $('#submit');
    this.fields = [
      new TextField(),
      new DateField(),
      new TimeField(),
    ];

    var fileField = new FileField();
    var imagePreview = new ImagePreview();
    imagePreview.on('close', function () {
      fileField.clear();
    });

    var self = this;
    this.$el.on('ajax:beforeSend', function (e) { // After click
      if (self.validate()) {
        return true;
      } else {
        e.preventDefault();
        e.stopPropagation();

        self.fields.forEach(function (field) {
          if (field.errors.length !== 0) {
            console.warn(field, field.errors);
            field.displayErrors();
          }
        });
        return false;
      }
    });

    this.$el.on('ajax:success', function (e) {
      var response = e.detail[0];
      console.log('success', response);
      SnackMessage.success(response['message']);

      ga('send', {
        hitType: 'event',
        eventCategory: 'Schedule Success'
      });
    });

    this.$el.on('ajax:error', function (e) {
      var response = e.detail[0];
      console.log('error', response);

      var message = response['error'];
      if (Array.isArray(message)) {
        message = message.join(I18n.delim);
      }
      SnackMessage.alert(message);
    });
  }

  validate() {
    console.log('Start form validation');
    var results = [];
    this.fields.forEach(function (field) {
      results.push(field.validate());
    });
    return results.every(r => r);
  }
}

window.Form = Form;

class Field {
  constructor() {
  }

  displayErrors() {
    if (this.errors.length === 0) {
      this.$errors_container.empty().hide();
    } else {
      var $ul = $('<ul>');
      this.errors.forEach(function (error) {
        var $er = $('<li>', {text: error});
        $ul.append($er);
      });
      this.$errors_container.append($ul).show();
    }
  }
}

class FileField extends Field {
  constructor() {
    super();
    var $el = this.$el = $('#input-image');
    this.$errors_container = $('#form_images_errors');
    this.errors = [];

    $('.upload-file').on('click', function () {
      $el.trigger('click');
    });

    var self = this;
    $el.change(function () {
      self.readFile(this.files);
    });
  }

  clear() {
    this.$el[0].value = '';
  }

  readFile(files) {
    // TODO Support multiple files

    if (files && files[0]) {
      var file = files[0];

      if (this.validate(file)) {
        var reader = new FileReader();

        reader.onload = function (e) {
          $('#live-preview .preview-image').attr('src', e.target.result);
          $('#live-preview .preview-image-container').show();
        };

        reader.readAsDataURL(file);
      } else {
        this.displayErrors();
      }
    }
  }

  validate(file) {
    this.errors = [];
    this.$errors_container.empty().hide();
    console.log('Start validation', this.constructor.name, file);

    if (file.type.match(/video|audio/i)) {
      this.errors.push(I18n.errors['videoNotAllowed']);
      return;
    }

    if (!Validation.content_types.includes(file.type)) {
      this.errors.push(I18n.errors['invalidContentType']);
      return;
    }

    if (file.size > Validation.max_size) { // 15 MB
      this.errors.push(I18n.errors['fileSizeTooBig']);
    }

    return this.errors.length === 0;
  }
}

class TextField extends Field {
  constructor() {
    super();
    this.$el = $('#input-text');
    this.$errors_container = $('#form_text_errors');
    this.errors = [];
    this.remainingMax = 280;

    this.$el.autosize();

    var self = this;
    this.$el.on('keyup', function () {
      self.displayPreview();
    });
  }

  displayPreview() {
    var previous = this.$el.data('previous');
    var current = this.$el.val();

    if (previous !== current) {
      console.log('input', current);
      this.setRemainingCount(this.remainingMax - Util.countChars(current));

      var str = Util.escapeTags(current).replace(/(?:\r\n|\r|\n)/g, '<br>');
      console.log('converted', str);

      $('#live-preview .tweet-preview').html(str);
      this.$el.data('previous', current);
      $('.tweet-text')[0].value = current;
    }
  }

  setRemainingCount(count) {
    $('.remaining-count').text(count);
  }

  validate() {
    this.errors = [];
    this.$errors_container.empty().hide();
    var val = this.$el.val();
    console.log('Start validation', this.constructor.name, val);

    if (!val || val === '') {
      this.errors.push(I18n.errors.text.blank);
      return;
    }

    return this.errors.length === 0;
  }
}


class DateField extends Field {
  constructor() {
    super();
    this.$el = $('#date-picker');
    this.$errors_container = $('#form_date_errors');
    this.errors = [];
  }

  validate() {
    this.errors = [];
    this.$errors_container.empty().hide();
    var val = this.$el.val();
    console.log('Start validation', this.constructor.name, val);

    if (!val || val === '') {
      this.errors.push(I18n.errors.date.blank);
      return;
    }

    return this.errors.length === 0;
  }
}

class TimeField extends Field {
  constructor() {
    super();
    this.$el = $('#time-picker');
    this.$errors_container = $('#form_time_errors');
    this.errors = [];
  }

  validate() {
    this.errors = [];
    this.$errors_container.empty().hide();
    var val = this.$el.val();
    console.log('Start validation', this.constructor.name, val);

    if (!val || val === '') {
      this.errors.push(I18n.errors.time.blank);
      return;
    }

    return this.errors.length === 0;
  }
}

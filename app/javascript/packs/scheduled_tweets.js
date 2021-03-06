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
      self.alertClosed();
      return false;
    });
  }

  alertClosed() {
    this.hidePreview();
    if (this.callback) {
      this.callback();
    }
  }

  fieldChanged() {
    this.hidePreview();
  }

  hidePreview() {
    $('#live-preview .preview-image-container').hide();
    $('#live-preview .preview-image').attr('src', null);
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
    this.textField = new TextField();
    this.dateField = new DateField();
    this.timeField = new TimeField();
    this.fileField = new FileField();

    this.$el.on('ajax:beforeSend', this.beforeSend.bind(this));
    this.$el.on('ajax:success', this.afterSuccess);
    this.$el.on('ajax:error', this.afterError);
  }

  validate() {
    console.log('Start form validation');

    var tweet = new ScheduledTweet({
      text: this.textField.val(),
      date: this.dateField.val(),
      time: this.timeField.val()
    });

    if (tweet.validate() && this.fileField.validate()) {
      return true;
    } else {
      this.textField.displayErrors(tweet.errors['text']);
      this.dateField.displayErrors(tweet.errors['date']);
      this.timeField.displayErrors(tweet.errors['time']);
      return false;
    }
  }

  beforeSend(e) {
    if (this.validate()) {
      return true;
    } else {
      e.preventDefault();
      e.stopPropagation();
      return false;
    }
  }

  afterSuccess(e) {
    var response = e.detail[0];
    console.log('success', response);
    SnackMessage.success(response['message']);

    ga('send', {
      hitType: 'event',
      eventCategory: 'Schedule Success'
    });
  }

  afterError(e) {
    var response = e.detail[0];
    console.log('error', response);

    var message = response['error'];
    if (Array.isArray(message)) {
      message = message.join(I18n.delim);
    }
    SnackMessage.alert(message);
  }
}

window.Form = Form;

//
// Field
//

class Field {
  constructor() {
  }

  displayErrors(errors) {
    this.$errors_container.empty().hide();
    if (!errors || errors.length === 0) {
      // Do nothing
    } else {
      var $ul = $('<ul>');
      errors.forEach(function (error) {
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

    var self = this;
    $el.change(function () {
      self.preview.fieldChanged();
      self.readFile(this.files);
    });

    this.preview = new ImagePreview();
    this.preview.on('close', function () {
      self.previewClosed();
    });
  }

  previewClosed() {
    this.$el[0].value = '';
  }

  readFile(files) {
    if (!files) {
      return;
    }

    if (!this.validate(files)) {
      return;
    }

    for (var i = 0; i < files.length; i++) {
      this.renderPreview(files[i], i);
    }
  }

  renderPreview(file, index) {
    var reader = new FileReader();

    reader.onload = function (e) {
      var container = $('#live-preview .preview-image-container');
      container.find('img.index-' + index).attr('src', e.target.result);
      container.show();
    };

    reader.readAsDataURL(file);
  }

  validate(files) {
    if (!files) {
      files = this.$el[0].files;
    }
    if (!files) {
      return true;
    }

    if (files.length > Validation.max_files) {
      this.displayErrors([I18n.errors['tooManyFiles']]);
      return false;
    }

    for (var i = 0; i < files.length; i++) {
      var result = this.validate_each(files[i]);
      if (!result) {
        return false;
      }
    }

    return true;
  }

  validate_each(file) {
    var validator = new FileValidator(file);
    var result = validator.validate();
    if (!result) {
      this.displayErrors(validator.errors);
    }
    return result;
  }
}

class TextField extends Field {
  constructor() {
    super();
    this.$el = $('#input-text');
    this.$errors_container = $('#form_text_errors');
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

  val() {
    return this.$el.val();
  }
}

class DateField extends Field {
  constructor() {
    super();
    this.$el = $('#date-picker');
    this.$errors_container = $('#form_date_errors');
  }

  val() {
    return this.$el.val();
  }
}

class TimeField extends Field {
  constructor() {
    super();
    this.$el = $('#time-picker');
    this.$errors_container = $('#form_time_errors');
  }

  val() {
    return this.$el.val();
  }
}

//
// Validator
//

class Validator {
  constructor(val) {
    this.val = val;
    this.errors = [];
  }
}

class FileValidator {
  constructor(file) {
    this.file = file;
    this.errors = null;
  }

  validate() {
    console.log('Start file validation', this.file);
    this.errors = [];

    if (!this.file) {
      return true;
    }

    if (this.file.type.match(/video|audio/i)) {
      this.errors.push(I18n.errors['videoNotAllowed']);
      return;
    }

    if (!Validation.content_types.includes(this.file.type)) {
      this.errors.push(I18n.errors['invalidContentType']);
      return;
    }

    if (this.file.size > Validation.max_size) { // 15 MB
      this.errors.push(I18n.errors['fileSizeTooBig']);
    }

    return this.errors.length === 0;
  }
}

class TextValidator extends Validator {
  constructor(val) {
    super(val);
  }

  validate() {
    console.log('Start text validation', this.val);

    if (!this.val || this.val === '') {
      this.errors.push(I18n.errors.text.blank);
      return;
    }

    return this.errors.length === 0;
  }
}

class DateValidator extends Validator {
  constructor(val) {
    super(val);
  }

  validate() {
    console.log('Start date validation', this.val);

    if (!this.val || this.val === '') {
      this.errors.push(I18n.errors.date.blank);
      return;
    }

    return this.errors.length === 0;
  }
}

class TimeValidator extends Validator {
  constructor(val) {
    super(val);
  }

  validate() {
    console.log('Start time validation', this.val);

    if (!this.val || this.val === '') {
      this.errors.push(I18n.errors.time.blank);
      return;
    }

    return this.errors.length === 0;
  }
}

class ScheduledTweet {
  constructor(attrs) {
    this.text = attrs['text'];
    this.date = attrs['date'];
    this.time = attrs['time'];
    this.tweetId = attrs['tweetId'];
    this.errors = null;
  }

  validate() {
    this.errors = {};

    var textValidator = new TextValidator(this.text);
    if (!textValidator.validate()) {
      this.errors['text'] = textValidator.errors;
    }

    var dateValidator = new DateValidator(this.date);
    if (!dateValidator.validate()) {
      this.errors['date'] = dateValidator.errors;
    }

    var timeValidator = new TimeValidator(this.time);
    if (!timeValidator.validate()) {
      this.errors['time'] = timeValidator.errors;
    }

    return Object.keys(this.errors).length === 0;
  }

  destroy() {
    var url = '/api/v1/scheduled_tweets/' + this.tweetId; // api_v1_scheduled_tweet_path(id: 'ID')
    console.log('destroy', url);
    $.ajax({
      url: url,
      type: 'POST',
      data: {'_method': 'DELETE'}
    }).done(function done(res) {
      console.log('done', res);
      SnackMessage.success(res['message']);
    }).fail(function failed(res) {
      console.log('fail', res);
    });
  }
}

window.ScheduledTweet = ScheduledTweet;

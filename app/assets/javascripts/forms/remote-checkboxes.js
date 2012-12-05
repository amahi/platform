var RemoteCheckbox = {

    /*
      options

        selector - css selector for checkboxes

        custom callbacks:
          beforeSend(RemoteCheckbox, checkbox)
          success(RemoteCheckbox, checkbox)
          complete(RemoteCheckbox, checkbox)

        spinnerParentSelector - where should search for .spinner

    */

    initialize: function(options) {

        var _this = this;
        var options = options || {};

        $(options['selector']).live('click', function() {

            options['beforeSend'] = typeof(options['beforeSend']) == 'undefined' ? function(){} : options['beforeSend'];
            options['success'] = typeof(options['success']) == 'undefined' ? function(){} : options['success'];
            options['complete'] = typeof(options['complete']) == 'undefined' ? function(){} : options['complete'];

            options['spinnerParentSelector'] = typeof(options['spinnerParentSelector']) == 'undefined' ? 'span:first' : options['spinnerParentSelector'];
            options['parentSelector'] = typeof(options['parentSelector']) == 'undefined' ? false : options['parentSelector'];

            var checkbox = $(this);

            checkbox.blur();

            if (typeof(checkbox.data('confirm')) == 'undefined') {
               run_request = true;
            } else {
               run_request = confirm(checkbox.data('confirm'));
            }

            if (run_request && typeof(checkbox.data('request')) == 'undefined') {
                $.ajax({
                    beforeSend: function() {
                        checkbox.data('request', true);
                        _this.toggle_spinner(options['spinnerParentSelector'], checkbox);
                        options['beforeSend'](_this, checkbox);
                    },
                    type: 'PUT',
                    url: _this.url(checkbox),
                    success: function(data) {
                        if (data['status'] == 'ok') {
                          options['success'](_this, checkbox, data);
                          checkbox.attr('checked', !checkbox.attr('checked'));
                        }
                        if (typeof(data['force']) != 'undefined') {
                            checkbox.attr('checked', data['force']);
                        }
                    },
                    complete: function() {
                        try {
                            _this.toggle_spinner(options['spinnerParentSelector'], checkbox);
                            options['complete'](_this, checkbox);
                            if (options['parentSelector']){
                                _this.highlight_parent(options['parentSelector'], checkbox);
                            }
                            checkbox.removeData('request');
                        } catch(e){}

                    }
                });
            }
            return false;
        });


    },

    url : function(element) { return $(element).data('url') },

    toggle_spinner: function(spinnerParentSelector, element) {
      $(element).parents(spinnerParentSelector).find('.spinner:first').toggle();
    },

    highlight_parent: function(parentSelector, element) {
        $(element).parents(parentSelector).effect('highlight');
    }


}

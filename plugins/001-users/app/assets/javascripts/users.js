var Users = {
    initialize: function() {

        var _this = this;

        // new user
        $('#new-user-form').live({
            'ajax:success': function(data, results, jqXHR){
                if (results['status'] != 'ok') {
                    _this.form().replaceWith(results['content']);
                } else {
			$('#users-table').parents('td:first').html(results['content']);
			_this.form().find("input[type=text], textarea").val("");
                }
                _this.form();
            }

        });

        // deleting user

        $('.delete-user').live({
            'ajax:success': function(data, results, jqXHR){
                user = $("#whole_user_" + results['id']);
                user.hide('slow');
                user.remove();
            }
        });

        $('.update-password').live({
            'ajax:success': function(data, results, jqXHR){
                msg = $(this).nextAll('.messages:first');
		msg.text(results['message']);
		setTimeout(function() { msg.text(''); }, 8000);
            },

            'ajax:complete': function(data, results, jqXHR){
                $(this).find('.spinner').hide();
                $(this).find('.password-edit').hide();
		$(this).find('input[type=password]').val('');
            },

            'ajax:beforeSend': function(data, results, jqXHR){
                $(this).find('.spinner').show('fast');
            }

        });

        // update username
        SmartLinks.initialize({
            open_selector: '.open-username-edit',
            close_selector: '.close-username-edit',
            onShow: function(open_link){
                user = _this.user(open_link);
                user_id = _this.parse_id(user.attr('id'));
                open_link.after(Templates.run('updateUsername', {user_id: user_id}));
                form = open_link.next();
                FormHelpers.update_first(form, open_link.text());
                FormHelpers.focus_first(form);
            }
        });

        $('.username-form').live({
            'ajax:success': function(data, results, jqXHR){
                if (results['status'] == 'ok') {
                  form = $(this);
                  link = form.prev();
                  value = FormHelpers.find_first(form).val();
                  link.text(value);
                }
            },

            'ajax:complete': function(data, results, jqXHR){
                form = $(this);
                link = form.prev();
                form.hide('slow', function(){
                    form.remove();
                    link.show();
                });

            }
        });

	// management of the public key area
        $('.update-pubkey').live({
            'ajax:success': function(data, results, jqXHR){
                form = $(this);
                spinner = form.parent().parent().children('.spinner');
		spinner.hide();
                if (results['status'] == 'ok') {
			image = form.parent().parent().children('.ok');
                } else {
			image = form.parent().parent().children('.error');
		}
		image.show();
		setTimeout(function() { image.hide('slow'); }, 3000);
            },
            'ajax:beforeSend': function(data, results, jqXHR){
                form = $(this);
                spinner = form.parent().parent().children('.spinner');
                spinner.show('fast');
                form.parent().hide();
            }
        });

        RemoteCheckbox.initialize({'selector': '.user_admin_checkbox', 'parentSelector': 'span:first', 'success': function(rc, checkbox) {
            _this.user(checkbox).find('.user_icons:first').toggleClass('user_admin');
            _this.delete_area_toggle(checkbox);
        }});

    },

    parse_id: function(html_id){
      return html_id.split('_').last();
    },

    user: function(finder){
        return typeof(finder) == "string" ? this.user_by_id(finder) : this.user_by_element(finder);
    },

    user_by_element: function(element) {
        return $(element).parents('.user:first');
    },

    user_by_id: function(id){
        return $('#whole_user_' + id);
    },

    delete_area_toggle: function(element){
      this.user(element).find('.delete:first').toggle();
    },



    form: function(element){
      return element ?  $(element).parents('form:first') :  $('#new-user-form');
    }

}


$(document).ready(function(){
    Users.initialize();
})

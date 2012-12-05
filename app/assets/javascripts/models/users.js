var Users = {
    initialize: function() {

        var _this = this;

        // new user
        $('#new-user-form').live({
            'ajax:success': function(data, results, jqXHR){
                if (results['status'] != 'ok') {
                    _this.form().replaceWith(results['content']);
                } else {
                    parent = $('#users').parents('td:first')
                    parent.html(results['content']);
                }
                _this.form().validate();
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

        // update password
        SmartLinks.initialize({
            open_selector: '.open-password-area',
            close_selector: '.close-password-area',
            onShow: function(open_link){
               user = _this.user(open_link);
               user_id = _this.parse_id(user.attr('id'));
               open_link.nextAll('.messages:first').text('');
               open_link.after(Templates.run('updatePassword', {user_id: user_id}));
               form = open_link.next().validate();
               FormHelpers.focus_first(form);
            }
        });

        $('.update-password-form').live({
            'ajax:success': function(data, results, jqXHR){
                form = $(this);
                form.nextAll('.messages:first').text(results['message']);
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




        // update username
        SmartLinks.initialize({
            open_selector: '.open-username-edit',
            close_selector: '.close-username-edit',
            onShow: function(open_link){
                user = _this.user(open_link);
                user_id = _this.parse_id(user.attr('id'));
                open_link.after(Templates.run('updateUsername', {user_id: user_id}));
                form = open_link.next().validate();
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

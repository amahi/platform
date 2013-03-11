var Shares = {
    initialize: function(){
        var _this = this;

        // deleting share
        $('.delete-share').live({
            'ajax:success': function(data, results, jqXHR){
                share = _this.share($(this));
                share.hide('slow');
                share.remove();
            }
        });

        // new share
        $('#new-share-form').live({
            'ajax:success': function(data, results, jqXHR){
                if (results['status'] != 'ok') {
                    _this.form().replaceWith(results['content']);
                } else {
                    parent = $('#shares-table');
                    parent.replaceWith(results['content']);
                }
            }

        });

        $('#share_comment').live('blur', function(){
            share_comment = $(this);
            share_path = $('#share_path');
            if(share_comment.val() != '' && share_path.val() == ''){
                share_path.val(share_path.data('pre')+share_comment.val());
                FormHelpers.focus(share_path);
            }

        })


        RemoteCheckbox.initialize({'selector': '.share_visible_checkbox', 'parentSelector': 'span:first'});


        RemoteCheckbox.initialize({'selector': '.share_everyone_checkbox, .share_access_checkbox, .share_guest_access_checkbox', 'parentSelector': 'span:first', 'spinnerParentSelector': '.access',
            'success': function(rc, checkbox, data){
                _this.update_access_area(checkbox, data['content']);
            }
        });

        RemoteCheckbox.initialize({'selector': '.share_readonly_checkbox, .share_write_checkbox, .share_guest_writeable_checkbox', 'parentSelector': 'span:first', 'spinnerParentSelector': '.access'});

        // update tags
        SmartLinks.initialize({
            open_selector: '.open-update-tags-area',
            close_selector: '.close-update-tags-area',
            onShow: function(open_link){
                share = _this.share(open_link);
                share_id = _this.parse_id(share.attr('id'));
                open_link.after(Templates.run('updateTags', {share_id: share_id}));
                form = open_link.next();
                FormHelpers.update_first(form, open_link.text());
                FormHelpers.focus_first(form);
            }
        });

        $('.update-tags-form').live({
            'ajax:success': function(data, results, jqXHR){
                form = $(this);
                share = _this.share(form);
                share.find('.tags:first').replaceWith(results['content']);
            }
        });

        RemoteCheckbox.initialize({'selector': '.share_tags_checkbox', 'parentSelector': 'span:first', 'spinnerParentSelector': '.tags',
            'success': function(rc, checkbox, data){
                checkbox = $(checkbox);
                share = _this.share(checkbox);
                share.find('.tags:first').replaceWith(data['content']);
            }
        });

        // update path
        SmartLinks.initialize({
            open_selector: '.open-update-path-area',
            close_selector: '.close-update-path-area',
            onShow: function(open_link){
                share = _this.share(open_link);
                share_id = _this.parse_id(share.attr('id'));
                open_link.after(Templates.run('updatePath', {share_id: share_id}));
                form = open_link.next();
                FormHelpers.update_first(form, open_link.text());
                FormHelpers.focus_first(form);
            }
        });

        $('.update-path-form').live({
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

        RemoteCheckbox.initialize({'selector': '.disk_pooling_checkbox', 'parentSelector': 'span:first'});

        RemoteCheckbox.initialize({'selector': '.disk_pool_checkbox', 'parentSelector': 'span:first',
            'success': function(rc, checkbox, data){
                checkbox = $(checkbox);
                share = _this.share(checkbox);
                share.find('.disk-pool:first').replaceWith(data['content']);
            }
        });

        // update extras
        SmartLinks.initialize({
            open_selector: '.open-update-extras-area',
            close_selector: '.close-update-extras-area',
            onShow: function(open_link){
                share = _this.share(open_link);
                share_id = _this.parse_id(share.attr('id'));
                open_link.after(Templates.run('updateExtras', {share_id: share_id}));
                form = open_link.next();
                FormHelpers.update_first(form, open_link.text());
                FormHelpers.focus_first(form);
            }
        });

        $('.update-extras-form').live({
            'ajax:success': function(data, results, jqXHR){
                if(results['status'] == 'ok') {
                    form = $(this);
                    link = form.prev();
                    text_area = FormHelpers.find_first(form);
                    value = $.trim(text_area.val());
                    value = (value == '') ? text_area.attr('placeholder') : value;
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

        $('.clear-permissions').live({
            'ajax:success': function(data, results, jqXHR){
                link = $(this);
                parent = link.parent();
                if (results['status'] == 'ok') {
			parent.html(FormHelpers.ok_icon)
                } else {
			parent.html(FormHelpers.error_icon)
		}
            },
            'ajax:beforeSend': function(data, results, jqXHR){
                link = $(this);
                spinner = link.parent().children('.spinner');
                spinner.show('fast');
                link.hide();
            }

        });


    },
    parse_id: function(html_id){
        return html_id.split('_').last();
    },

    share: function(finder){
        return typeof(finder) == "string" ? this.share_by_id(finder) : this.share_by_element(finder);
    },

    share_by_element: function(element) {
        return $(element).parents('.share:first');
    },

    share_by_id: function(id){
        return $('#whole_share_' + id);
    },

    access_area: function(element){
        return this.share(element).find('.access:first');
    },

    update_access_area: function(element, content){
        this.access_area(element).html(content);
    },

    form: function(element){
        return element ?  $(element).parents('form:first') :  $('#new-share-form');
    }

}


$(document).ready(function(){
    Shares.initialize();
})

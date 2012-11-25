var FormHelpers = {

    find_first : function(area){
        form_element = area.find('input[type=text],textarea').filter(':visible:first');
        return $(form_element);
    },

    update_first: function(area, value) {
        form_element = this.find_first(area)
        if(form_element != null) {
            if(form_element.attr('placeholder') != value){
              form_element.val(value);
            }
        }
    },

    focus_first: function(area){
        form_element = area.find('input[type=text],input[type=password],textarea').filter(':visible:first');
        if(form_element != null) {
           this.focus(form_element);
        }
    },

    focus: function(element){
        element.focus();

        // set cursor on the end
        value = $.trim(element.val());
        element.val('');
        element.val(value);
    },


    ok_icon: function(element){
        return '<img src="' + ok_icon_path + '" />';
    },

    error_icon: function(element){
        return '<img src="' + error_icon_path + '" />';
    },

    elementFail: function(element, message){
        message = this.error_icon(element) + ' ' + message;
        this.writeElementMessage(element, message);
    },

    elementPass: function(element, message){
        message = this.ok_icon(element);
        this.writeElementMessage(element, message);
    },

    writeElementMessage: function(element, message) {
        element.parents('tr:first').find('.messages').html(message);
    }


}
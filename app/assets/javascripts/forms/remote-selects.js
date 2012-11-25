var RemoteSelect = {

    /*
     options

     selector - css selector for selects

     custom callbacks:
     beforeSend(RemoteSelect, select)
     success(RemoteSelect, select
     complete(RemoteSelect, select)

     spinnerParentSelector - where should search for .spinner

     */

    initialize: function(options){

        var _this = this;
        var options = options || {};

        $(options['selector']).live('change', function(){

            options['beforeSend'] = typeof(options['beforeSend']) == 'undefined' ? function(){} : options['beforeSend'];
            options['success'] = typeof(options['success']) == 'undefined' ? function(){} : options['success'];
            options['complete'] = typeof(options['complete']) == 'undefined' ? function(){} : options['complete'];

            options['spinnerParentSelector'] = typeof(options['spinnerParentSelector']) == 'undefined' ? 'span:first' : options['spinnerParentSelector'];
            options['parentSelector'] = typeof(options['parentSelector']) == 'undefined' ? false : options['parentSelector'];

            var select = $(this);

            select.blur();

            if(typeof(select.data('confirm')) == 'undefined') {
                run_request = true;
            }
            else {
                run_request = confirm(select.data('confirm'));
            }

            if(run_request && typeof(select.data('request')) == 'undefined') {
                $.ajax({
                    beforeSend: function(){
                        select.data('request', true);
                        _this.toggle_spinner(options['spinnerParentSelector'], select);
                        options['beforeSend'](_this, select);
                    },
                    type: 'PUT',
                    url: _this.url(select),
                    success: function(data) {
                        if(data['status'] == 200) {
                            options['success'](_this, select, data);
                        }
                    },
                    complete: function(){
                        try {
                            _this.toggle_spinner(options['spinnerParentSelector'], select);
                            options['complete'](_this, checkbox);
                            if(options['parentSelector']){
                                _this.highlight_parent(options['parentSelector'], select);
                            }
                            select.removeData('request');
                        } catch(e){}

                    }
                });
            }
            return false;
        });


    },

    url : function(element) {return $(element).data('url')},

    toggle_spinner: function(spinnerParentSelector, element){
        $(element).parents(spinnerParentSelector).find('.spinner:first').toggle();
    },

    highlight_parent: function(parentSelector, element){
        $(element).parents(parentSelector).effect('highlight');
    }


}
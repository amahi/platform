var Apps = {
    initialize: function(){
        var _this = this;

        $('.install-app-via-deamon, .uninstall-app-via-deamon').live({

            'ajax:beforeSend': function(jqXHR, settings){
                $('.install-button').hide();
                _this.toggle_spinner(this);
            },

            'ajax:success': function(data, results, jqXHR){
                _this.update_progress(results['identifier'], results['content']);
                _this.trace_progress(results['identifier']);
            }

        });

        RemoteCheckbox.initialize({'selector': '.in_dashboard_checkbox', 'parentSelector': 'span:first'});


    },

    app: function(finder){
       return typeof(finder) == "string" ? this.app_by_identifier(finder) : this.app_by_element(finder);
    },

    app_by_element: function(element) {
       return $(element).parents('.app:first');
    },

    app_by_identifier: function(identifier){
       return $('#app_whole_' + identifier);
    },

    toggle_spinner: function(finder){
        var app = this.app(finder);
        app.find('.spinner-installation').toggle();
    },

    progress: function(finder){
        return this.app(finder).find('.progress:first');
    },

    update_progress: function(finder, content){
        this.progress(finder).html(content);
    },

    progress_message: function(finder) {
       return this.app(finder).find('.install_progress');
    },

    update_progress_message: function(finder, content){
       this.progress_message(finder).html(content);
    },

    show_app_flash_notice: function(finder){
      var app = this.app(finder);
      var notice = app.find('.app-flash-notice');
      notice.show();
    },


    update_installed_app: function(finder, content){
       var _this = this;
       var app = this.app(finder);
       app.replaceWith(content);
       _this.show_app_flash_notice(finder);
       $('.install-button').show();
    },

    update_uninstalled_app: function(finder){
        this.app(finder).remove();
        $('.install-button').show();
    },


    trace_progress: function(finder){
      var _this = this;
      $.ajax({
         url: _this.app(finder).data('progressPath'),
         success: function(data){
             _this.update_progress_message(finder, data['content'])
             if(data['app_content']){
                 _this.update_installed_app(finder, data['app_content']);
             }
             else if(data['uninstalled']) {
                 _this.update_uninstalled_app(finder);
             }
             else {
                 setTimeout("Apps.trace_progress('"+finder+"')", 2000);
             }
         }
      })
    }

}

$(document).ready(function(){
  Apps.initialize();
})
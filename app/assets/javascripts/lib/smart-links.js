var SmartLinks = {
    /*
     options

     open_selector - css selector
     open_area_selector - css selector
     close_selector - css selector

     custom callbacks:
       onShow(SmartLinks)
       onHide(SmartLinks)



     */

    initialize: function(options){

        var _this = this;
        var options = options || {};

        $(document).on("click", options['open_selector'], function(){

            options['onShow'] = typeof(options['onShow']) == 'undefined' ? function(){} : options['onShow'];

            open_link = $(this);
            open_link.hide();

            if(typeof(open_link.data('related')) != 'undefined') {
                related = $(open_link.data('related'));
                related.show('slow');
                FormHelpers.focus_first(related);
            }

            options['onShow'](open_link);

            return false;
        });

        $(document).on("click", options['close_selector'], function(){

            options['onHide'] = typeof(options['onHide']) == 'undefined' ? function(){} : options['onHide'];
            options['open_area_selector'] = typeof(options['open_area_selector']) == 'undefined' ? '.area' : options['open_area_selector'];


            close_link = $(this);

            open_area = close_link.parents(options['open_area_selector'] + ':first');
            open_area.hide('slow');
	    open_area.find("input[type=text], input[type=password], textarea").val('');

            if (typeof(close_link.data('related')) != 'undefined') {
		$(close_link.data('related')).delay(400).show('slow');
            } else {
		open_area.prev().delay(400).show('slow');
            }
            options['onHide'](open_area);
            return false;
        })

    }

}

$(document).ready(function(){

    $('.stretchtoggle').live('click', function(){
        $(this).parents('div:first').find('.settings-stretcher:first').toggle();
        return false;
    });

    SmartLinks.initialize({
        open_selector: '.open-area',
        close_selector: '.close-area'
    })

    $('.focus').live({
        'mouseenter':  function(){
          $(this).css('background-color', 'rgb(255,255,153)');
        },
        'mouseleave':  function(){
            $(this).css('background-color', 'transparent');
        }
    })

});
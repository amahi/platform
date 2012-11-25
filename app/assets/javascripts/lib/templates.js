var Templates = {
  run: function(name, params){
    return $('#'+name+'Template').tmpl(params)
  }
}
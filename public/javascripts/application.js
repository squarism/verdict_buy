// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function log( message ) {
	$( "<div/>" ).text( message ).prependTo( "#log" );
	$( "#log" ).attr( "scrollTop", 0 );
}

jQuery(document).ready(function(){
	jQuery("#search").autocomplete({
		source: "/loves/find_titles.json",
		dataType: "json",
		focus: function(event, ui) {
		    $('#search').val(ui.item.name);
				//log(ui.item.id);
		    return false;
		},
		minLength: 2,
		select: function( event, ui ) {
			log( ui.item ?
				"Selected: " + ui.item.name + " aka " + ui.item.id :
				"Nothing selected, input was " + this.value );
		}
	}).data( "autocomplete" )._renderItem = function( ul, item ) {
		return $( "<li></li>" )
		.data( "item.autocomplete", item )
		.append( "<a>" + item.name + "</a>" )
		.appendTo( ul );
    };
});
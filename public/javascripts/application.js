// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function log( message ) {
	$( "<div/>" ).text( message ).prependTo( "#log" );
	$( "#log" ).attr( "scrollTop", 0 );
}

function set_text(text) {
	alert(text);
	$(this).val(text);
}

var last_auto = "";
var last_id = "";

// autocomplete magic function
var box_handler = function() {
	// alert($(this).val());
	$(this).autocomplete({
		source: "/loves/find_titles.json",
		dataType: "json",
		focus: function(event, ui) {
		    $(this).val(ui.item.name);
				//log(ui.item.id);
		    return false;
		},
		minLength: 2,
		select: function( event, ui ) {
			last_auto = ui.item.name;
			last_id = ui.item.id;
			log("selected ID:" + ui.item.id);
		},
		close: function(event, ui) {
			$(this).val(last_auto);
			
			// search_1 -> gbid_1
			var id = this.id.split("_");
			var brother = "#gbid_" + id[1];
			$(brother).val(last_id);
			log(brother);
		}
	}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.name + "</a>" )
			.appendTo( ul );
   };
}

jQuery(document).ready(function(){
	
	// select all search textboxes
	$('.autosearch').val('foo');
	
	// bind the autocomplete magic to them
	$('.autosearch').each(function(i, val){
		$(this).val('foo' + i);
		$(this).bind('focus', box_handler);
	});
	
	// jQuery("#search").autocomplete({
	// 	source: "/loves/find_titles.json",
	// 	dataType: "json",
	// 	focus: function(event, ui) {
	// 	    $('#search').val(ui.item.name);
	// 			//log(ui.item.id);
	// 	    return false;
	// 	},
	// 	minLength: 2,
	// 	select: function( event, ui ) {
	// 		log( ui.item ?
	// 			"Selected: " + ui.item.name + " aka " + ui.item.id :
	// 			"Nothing selected, input was " + this.value );
	// 	}
	// }).data( "autocomplete" )._renderItem = function( ul, item ) {
	// 	return $( "<li></li>" )
	// 	.data( "item.autocomplete", item )
	// 	.append( "<a>" + item.name + "</a>" )
	// 	.appendTo( ul );
	//     };
});
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// #1
// jQuery(document).ready(function($) {
// 	  // when the #search field changes
// 	  $("#search").change(function() {
// 			alert("CHANGE");
// 	    // make a POST call and replace the content
// 	    // $.post(<%= live_search_path %>, function(data) {
// 	    //   $("#results").html(data);
// 	    // });
// 	  });
// });

// #2 & #3
function log( message ) {
	$( "<div/>" ).text( message ).prependTo( "#log" );
	$( "#log" ).attr( "scrollTop", 0 );
}

// #2
// jQuery(document).ready(function($) {
// 	
// // $(function() {
// 	alert("blah");
// 
// 	$( "#search" ).autocomplete({
// 		source: <%= live_search_path %>,
// 		minLength: 2,
// 		select: function( event, ui ) {
// 			log( ui.item ?
// 				"Selected: " + ui.item.value + " aka " + ui.item.id :
// 				"Nothing selected, input was " + this.value );
// 		}
// 	});
// });

// #3
jQuery(document).ready(function(){
	// alert("blah");
	var availableTags = [ "java", "javascript", "ruby", "perl"];
	jQuery("#search").val("foo");
	jQuery("#search").autocomplete({
		source:availableTags,
		minLength: 2,
		select: function( event, ui ) {
			log( ui.item ?
				"Selected: " + ui.item.value + " aka " + ui.item.id :
				"Nothing selected, input was " + this.value );
		}
	});
	jQuery("#search").val("done");
});
function log( message ) {
	$( "<div/>" ).text( message ).prependTo( "#log" );
	$( "#log" ).attr( "scrollTop", 0 );
}

// Return an array of search textboxes.  Use like this:
// var placeholders = find_placeholders();
// for (var i in placeholders) {
// 	 var placeholder = $('#' + placeholders[i]);

function find_placeholders() {
	var a = new Array();
	$(".autosearch").each(function() {
		a.push($(this).attr('id'));
	});
	
	return a;
}

function set_text(text) {
	alert(text);
	$(this).val(text);
}

// Name: new name from autocorrect box
// ID: id from love table (cleaned up games)
// GBID: the id from giant bomb
function correct_name(name, gbid, id) {
	$.ajax({
		url: '/loves/revise_title.json',
		contentType: 'application/json',
		data: JSON.stringify({ page: { "name":name, "id":id, "gbid":gbid } }),
		dataType: 'json',
		type: 'PUT',
		success: function(data,text){
		// 	// put everything in here or it won't run on click
		// 	// batchId = data.batchId;
		log(data);
		// 	//$("#progressbar").show();
		}
	});
}

function update_owned(id, value) {
	$.ajax({
		url: '/loves/update_owned.json',
		contentType: 'application/json',
		data: JSON.stringify({ "id":id, "value":value } ),
		dataType: 'json',
		type: 'PUT'
	});
}

function update_ignored(id, value) {
	$.ajax({
		url: '/loves/update_ignored.json',
		contentType: 'application/json',
		data: JSON.stringify({ "id":id, "value":value } ),
		dataType: 'json',
		type: 'PUT'
	});
}

// we need these as globals to set the pairs
var last_auto = "";
var last_id = "";
var love_id = "";

// Title text box and ID fields are tied.
// IDs are cleaner so we'll update the UI and then later use that for search.
// This function does autocomplete search on the title field and then sets the ID column
// on the UI.  Interactive cleanup using GB has a structured source.
var box_handler = function() {
	$(this).autocomplete({
		source: "/loves/find_titles.json",
		dataType: "json",
		
		// updates textbox as you search
		focus: function(event, ui) {
		    $(this).val(ui.item.name);
				//log(ui.item.id);
		    return false;
		},
		minLength: 3,
		//timeout: 5000,
		validSelection: true,
		
		// when you hit enter
		select: function( event, ui ) {
			last_auto = ui.item.name;
			last_id = ui.item.id;
			log("selected ID:" + ui.item.id);
		},
		
		// when you're done searching
		close: function(event, ui) {
			$(this).val(last_auto);
			// search_1 -> gbid_1
			$('#love_gb_id').val(last_id);
			correct_name(last_auto, last_id, love_id);
			// send a save message to the controller saying we are overriding the title
			log("set hidden gb_id to:" + last_id);
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
	//$('.autosearch').val('foo');
	
	// bind the autocomplete magic to them
	$('.autosearch').each(function(i, val){
		//$(this).val('foo' + i);
		$(this).bind('focus', box_handler);
	});
	
	// get our hidden field to store our model id from rails
	love_id = $('#love_id').val();
	
	// ownership and ignore update boxes
	$('#love_owned').click(function() {
		log("click:" + $(this).attr('checked'));
		update_owned(love_id, $(this).attr('checked'));
	});
	$('#love_ignored').click(function() {
		log("click:" + $(this).attr('checked'));
		update_ignored(love_id, $(this).attr('checked'));
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
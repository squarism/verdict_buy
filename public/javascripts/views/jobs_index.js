function log( message ) {
	$( "<div/>" ).text( message ).prependTo( "#log" );
	$( "#log" ).attr( "scrollTop", 0 );
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

var click_handler = function() {
	// go up one in the form and find the hidden field for the model id
	var love_id = $(this).parent().find('#love_id').val();
	update_ignored(love_id, $(this).attr('checked'));
}

jQuery(document).ready(function(){
	$('.unignore_checkbox').each(function(i,val){
		$(this).bind('click', click_handler);
	});
	
	$('#love_ignored').click(function() {
		// alert("CLICK");
		// log("click:" + $(this).attr('checked'));
		// update_ignored(love_id, $(this).attr('checked'));
	});
});
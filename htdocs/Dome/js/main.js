		$(function(){

			window.previous_server_data = null;
			var request_interval 		= 1000;

			function Ajax(){

				var id 			   		= null;
				var elem_in_string 		= null;
				var appearance_interval = 1000;

				elem_in_string = location.href.toString().search(/\d{3}(?=.html)/);

				if(elem_in_string != -1){
					id = +(location.href.toString().slice(elem_in_string, elem_in_string + 3));
				}
				
				if(id == NaN || !(!!~elem_in_string)){
					id = 101;     // если не нашли id в заголовке пути, то ставим по умолчанию
				}
			
				$.get( "img.php", {id : id}, function( data, response_type ){
					console.log('Now')
					if(data == window.previous_server_data){
						setTimeout(Ajax, request_interval);
						return;
					}

					window.previous_server_data = data;

					if(response_type == 'success'){

						$.when(
							$('img#main_img').fadeOut(appearance_interval)
						).then(
							function(){
								$.when(
									$('img#main_img').attr('src', data).fadeIn(appearance_interval)
								).then(
									function(){
										Ajax();
									}
								)
							}
						);
					}
					else{
						console.log(response_type);
					}
					
				});
			};

			// setInterval(function(){ Ajax(); }, request_interval);
			setTimeout(function(){Ajax(); }, request_interval);
	
		});

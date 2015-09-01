$(function () {

	currentNav = $('.nav li.active').attr('id');

	$('.contents').bind('click', function(e) {
		e.preventDefault();
		// if ($('.topbar').css('top') != "-46px") {
		// 	$('.topbar').animate({top: '-46px'}, 1000);
		// 	$('.mainnav').slideDown(1200);
		// } else {
		// 	$('.mainnav').slideUp(1200);
		// 	$('.topbar').animate({top: '0'}, 1000);		
		// }
		// $('.mainnav').slideToggle(200);
		// $('.mainnav').slideToggle();
	});

	var activeNav = $('.nav li.active').attr('id');
	$('.sub div:not(.'+activeNav+' #azTags)').hide();
	
	$("pre").snippet("javascript",{style:"acid"});
	$("pre.arguments").snippet("javascript",{style:"acid"});
	$("pre.cfml").snippet("html",{style:"acid"});
	$("pre.arguments").snippet("css",{style:"acid"});

	$('.closemenu img').bind('click', function(e) {
		$('.nav li').removeClass('active');
		
		$('.mainnav').slideUp(200);

		$('#'+currentNav).addClass('active');
	});

	// $('div:not(.topbar)').bind('click', function() {
	// 	$('.mainnav').slideUp(200);
	// });


	/* Main Nav */
	/*$('.nav li').bind('click', function(e) {
		e.preventDefault();

		var item = $(this).attr('id');

		if ($('.mainnav').is(':visible') ) {

			$('.sub > div').hide();
			$('.sub div.'+item).fadeIn();

		} else {

			$('.sub > div').hide();
			$('.sub div.'+item).show();

			$('.mainnav').delay(200).slideDown(400);

		}

		$('.nav li').removeClass('active');
		$(this).addClass('active');



	});*/

	/* Tags Sub Menu */
	// $('.cats').hide();
	$('.tag-menu li').bind('click', function(e) {
		e.preventDefault();

		$('.tag-menu li').removeClass('here');
		var item = $(this).attr('data-id'); 
		$(this).addClass('here');

		$('#tagCats, #azTags, #functagCats, #funcazTags').hide();

		$('#'+item).show();

	});

	/* A-Z Nav */
	$('ul[class^=tags], ul[class^=funcs]').hide();

	$('#azTags .pills li').bind('click', function(e) {
		e.preventDefault();

		var item = $(this).attr('class');

		$('ul[class^=tags]').hide();
		$('.az-tags').show();
		$('.az-tags ul.'+item).show();

		$('li[class^=tags]').removeClass('active');
		$(this).addClass('active');

	});

	$('#funcazTags .pills li').bind('click', function(e) {
		e.preventDefault();

		var item = $(this).attr('class');

		$('ul[class^=funcs]').hide();
		$('.az-functions').show();
		$('.az-functions ul.'+item).show();

		$('li[class^=funcs]').removeClass('active');
		$(this).addClass('active');

	});
	
	$('#show_menu').click(function() {
		$('.nav').toggleClass('mobile');		
	});
	
	$('#side_menu').click(function() {
		$('.categories').toggleClass('collapse');
		$('.show_cats').toggleClass('active');
	});

});
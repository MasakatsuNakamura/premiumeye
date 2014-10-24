/* global $ */
$(function(){

	"use strict";

	$(".btn-top-nav").find("a")
		.on("click", function(){
			var $this = $(this),
				$nav = $("nav.top-nav");

			if($this.hasClass("icon-menu")){
				$this
					.removeClass("icon-menu")
					.addClass("icon-menu-close");

				$nav
					.velocity("stop")
					.velocity({
					right:0
				});
			} else {
				$this
					.removeClass("icon-menu-close")
					.addClass("icon-menu");
				$nav
					.velocity("stop")
					.velocity({
						right:"-50%"
					});
			}
		});
});

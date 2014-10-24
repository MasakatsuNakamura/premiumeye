module.exports = function(grunt) {

	'use strict';

	grunt.initConfig({
		watch : {
			deploy:{
				files:['src/**'],
				tasks:['deploy']
			}
		},
		jade:{
			options:{
				pretty:true // コードを整形出力するか
			},
			deploy_pc:{
				options:{
					data:jadeDataFunc("pc")
				},
				files:[{
					expand:true,
					cwd:'src/jade/pc',
					src:[
						'*.jade'
					],
					dest:'deploy',
					ext:'.html'
				}]
			},
			deploy_sp:{
				options:{
					data:jadeDataFunc("sp")
				},
				files:[{
					expand:true,
					cwd:'src/jade/sp',
					src:[
						'*.jade'
					],
					dest:'deploy/sp',
					ext:'.html'
				}]
			}
		}
	});
	function jadeDataFunc(env) {
		return function(dest, srcAr) {
			var _ = grunt.util._,
				regDest = /\/([A-Za-z_0-9-]+?)\.html/,
				destName = dest.match(regDest)[1],
				data;
			try {
				data = grunt.file.readJSON("src/json/_common.json");
			} catch(e) {
				data = {};
			}
			return _.extend({
				env:env,
				page:destName
			}, data);
		};
	}

	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-jade');
	grunt.registerTask('deploy', ['jade']);

	grunt.loadTasks('tasks');

	grunt.registerTask('default', ['deploy']);
};

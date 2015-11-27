module.exports = function(grunt) {

  'use strict';

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    s3auth: grunt.file.readJSON('s3auth.json'),
    s3: {
      options: {
        key: '<%= s3auth.key %>',
        secret: '<%= s3auth.secret %>',
        region: 'ap-northeast-1',
        bucket: 'sanix-data-analysis',
        access: 'authenticated-read'
      },
      build: {
        upload: [
          { src: 'deploy/**', dest: 'root' }
        ]
      }
    },
    watch : {
      deploy:{
        files:['**'],
        tasks:['deploy']
      }
    },
    coffee: {
      deploy:{
        files:[{
          expand:true,
          cwd:'coffee',
          src:[
          '*.coffee'
          ],
          dest:'deploy',
          ext:'.js'
        }]
      }
    },
    jade: {
      options:{
        data:jadeDataFunc(),
        pretty:true // コードを整形出力するか
      },
      deploy:{
        files:[{
          expand:true,
          cwd:'jade',
          src:[
          '*.jade'
          ],
          dest:'deploy',
          ext:'.html'
        }],
      }
    }
  });

  function jadeDataFunc() {
    return function(dest, srcAr) {
      var _ = grunt.util._,
      regDest = /\/([A-Za-z_0-9-]+?)\.html/,
      destName = dest.match(regDest)[1],
      data;
      try {
        data = grunt.file.readJSON("json/_common.json");
      } catch(e) {
        data = {};
      }
      return _.extend({
        page:destName
      }, data);
    };
  }

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-jade');
  grunt.loadNpmTasks('grunt-s3');
  grunt.registerTask('upload', 's3');
  grunt.registerTask('deploy', ['jade', 's3']);

  grunt.loadTasks('tasks');

  grunt.registerTask('default', ['deploy']);
};

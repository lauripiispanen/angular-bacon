module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    // Metadata.
    pkg: grunt.file.readJSON('package.json'),
    // Task configuration.
    coffee: {
      lib: {
        expand: true,
        flatten: true,
        cwd: 'src',
        src: '*.coffee',
        dest: 'dist',
        ext: '.js'
      }
    },
    uglify: {
      options: {
      },
      dist: {
        src: '<%= coffee.lib.dest %>/*.js',
        dest: 'dist/<%= pkg.name %>.min.js'
      }
    },
    watch: {
      gruntfile: {
        files: '<%= jshint.gruntfile.src %>',
        tasks: ['jshint:gruntfile']
      },
      lib_test: {
        files: '<%= jshint.lib_test.src %>',
        tasks: ['jshint:lib_test', 'qunit']
      }
    }
  });

  // Default task.
  grunt.registerTask('default', ['coffee', 'uglify']);

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');

};
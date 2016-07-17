component {
  /* Java lib source https://github.com/goochjj/SimpleWSDLEchoServer */
  /* See https://luceeserver.atlassian.net/projects/LDEV/issues/LDEV-933 */
  public any function init(numeric port) {
    var parentcl = createObject( "java", "ClassLoader" ).getSystemClassLoader();
    var urls = [ createobject("java", "java.io.File").init(getDirectoryFromPath( getCurrentTemplatePath() )&"/SimpleWSDLEchoServer.jar").toURL() ];
    Variables.ClassLoader = createobject("java","java.net.URLClassLoader").init(urls.toArray(), parentCL);
    var meth = Variables.ClassLoader.loadClass("org.goochfriend.simplewsdlechoserver.SimpleHTTPServer").getConstructors();
    Variables.server = meth[1].newInstance([javacast("int",port)].toArray());
  }

  public any function get() { return Variables.server; }
  public any function start() { return Variables.server.start(); }
  public any function stop() { return Variables.server.stop(); }
  public any function join() { return Variables.server.join(); }
}

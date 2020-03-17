package pilot.router;

using StringTools;

class StaticHistory implements History {
  
  final onPopState:Signal<String> = new Signal();
  var root:String;
  var currentUrl:String;

  public function new(?initUrl) {
    currentUrl = initUrl;
  }
  
  public function setRoot(root:String) {
    this.root = root;
  }

  public function getLocation() {
    var path = currentUrl;
    if (path.startsWith(root)) {
      return path.substring(root.length);
    }
    return path;
  }

  public function push(url:String) {
    currentUrl = url;
    onPopState.dispatch(getLocation());
  }

  public inline function subscribe(listener) {
    return onPopState.add(listener);
  }

}

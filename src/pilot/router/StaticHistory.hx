package pilot.router;

class StaticHistory implements History {
  
  final onPopState:Signal<String> = new Signal();
  var currentUrl:String;

  public function new(?initUrl) {
    currentUrl = initUrl;
  }
  
  public function getLocation() {
    return currentUrl;
  }

  public function push(url:String) {
    currentUrl = url;
    onPopState.dispatch(getLocation());
  }

  public inline function subscribe(listener) {
    return onPopState.add(listener);
  }

}

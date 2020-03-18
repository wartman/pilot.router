package pilot.router;

import js.Browser;
import pilot.Signal;

class HashHistory implements History {

  final onChange:Signal<String> = new Signal();

  public function new() {
    Browser.window.addEventListener('popstate', (e) -> {
      onChange.dispatch(getLocation());
    });
  }
  
  public function getLocation():String {
    return getHashPath();
  }
  
  public function push(path:String):Void {
    Browser.window.history.pushState(null, null, parseHash(path));
    onChange.dispatch(getLocation());
  }
  
  public function subscribe(listener:SignalListener<String>):SignalSubscription<String> {
    return onChange.add(listener);
  }

  function parseHash(path:String) {
    return stripHash(Browser.window.location.href) + '#' + path;
  }

  function stripHash(url:String) {
    var index = url.indexOf('#');
    return index == - 1 ? url : url.substring(0, index); 
  }

  function getHashPath() {
    // We can't use window.location.hash here because it's not
    // consistent across browsers - Firefox will pre-decode it!
    var href = Browser.window.location.href;
    var index = href.indexOf('#');
    return index == - 1 ? '' : href.substring(index + 1); 
  }

}
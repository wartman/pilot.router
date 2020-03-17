package pilot.router;

import pilot.Signal;

interface History {
  public function setRoot(root:String):Void;
  public function getLocation():String;
  public function push(url:String):Void;
  public function subscribe(listener:SignalListener<String>):SignalSubscription<String>;
}

package pilot.router;

import pilot.Signal;

interface History {
  public function getLocation():String;
  public function push(url:String):Void;
  public function subscribe(listener:SignalListener<String>):SignalSubscription<String>;
}

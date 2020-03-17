package pilot.router;

import pilot.Component;
import pilot.Children;

class Router extends Component {

  // not sure about `root` here
  @:attribute var root:String = '';
  @:attribute var children:Children;
  @:attribute var history:History;

  @:init
  public function setRoot() {
    history.setRoot(root);
  }

  override function render() return html(
    <HistoryProvider value={history}>
      {children}
    </HistoryProvider>
  );

}

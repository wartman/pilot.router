package pilot.router;

import pilot.Component;
import pilot.Children;
import pilot.Provider;

class RouteContextProvider extends Component {
  
  @:attribute var url:String;
  @:attribute var children:Children;
  var context:RouteContext = new RouteContext();

  override function render() {
    context.setPath(url);
    return html(
      <Provider id={RouteContext.ID} value={context}>
        {children}
      </Provider>
    );
  }

}

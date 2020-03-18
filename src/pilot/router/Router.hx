package pilot.router;

import pilot.Component;
import pilot.Children;
import pilot.Provider;

/**
  The Router provides context for nested Routes and
  Links. It should be on the top-level of your app.
**/
class Router extends Component {

  public static final HISTORY_ID = Type.getClassName(Router) + '#History';

  @:attribute var history:History;
  @:attribute var children:Children;

  override function render() return html(
    <Provider id={HISTORY_ID} value={history}>
      {children}
    </Provider>
  );

}

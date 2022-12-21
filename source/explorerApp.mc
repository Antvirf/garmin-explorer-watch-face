import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class explorerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {}
    function onStop(state as Dictionary?) as Void {}

    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new explorerView() ] as Array<Views or InputDelegates>;
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

}

function getApp() as explorerApp {
    return Application.getApp() as explorerApp;
}

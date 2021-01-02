/*
 * Copyright (c) 2020 Payson Wallach
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

public class Zeitgeist.Plugin : Gala.Plugin {
    private Gala.AppCache app_cache;
    private Gala.WindowManager wm;
    private string? last_seen_desktop_url;
    private string? last_seen_window_title;

    public override void initialize (Gala.WindowManager wm) {
        this.wm = wm;
        last_seen_desktop_url = null;
        last_seen_window_title = null;
        app_cache = new Gala.AppCache ();

#if HAS_MUTTER330
        var display = wm.get_display ();
        foreach (unowned Meta.WindowActor actor in display.get_window_actors ()) {
            if (actor.is_destroyed ())
                continue;

            unowned Meta.Window window = actor.get_meta_window ();
            if (window.window_type == Meta.WindowType.NORMAL)
                monitor_window (window);
        }

        display.window_created.connect (on_window_created);
#else
        var screen = wm.get_screen ();
        foreach (unowned Meta.WindowActor actor in screen.get_window_actors ()) {
            if (actor.is_destroyed ())
                continue;

            unowned Meta.Window window = actor.get_meta_window ();
            if (window.window_type == Meta.WindowType.NORMAL)
                monitor_window (window);
        }

        screen.get_display ().window_created.connect (on_window_created);
#endif
    }

    public override void destroy () {
#if HAS_MUTTER330
        var display = wm.get_display ();
        foreach (unowned Meta.WindowActor actor in display.get_window_actors ()) {
            if (actor.is_destroyed ())
                continue;

            unowned Meta.Window window = actor.get_meta_window ();
            if (window.window_type == Meta.WindowType.NORMAL)
                monitor_window (window);
        }

        display.window_created.disconnect (on_window_created);
#else
        var screen = wm.get_screen ();
        foreach (unowned Meta.WindowActor actor in screen.get_window_actors ()) {
            if (actor.is_destroyed ())
                continue;

            unowned Meta.Window window = actor.get_meta_window ();
            if (window.window_type == Meta.WindowType.NORMAL)
                unmonitor_window (window);
        }

        screen.get_display ().window_created.disconnect (on_window_created);
#endif
    }

    private void monitor_window (Meta.Window window) {
        window.focused.connect (window_focused);
        window.unmanaged.connect (unmonitor_window);
    }

    private void unmonitor_window (Meta.Window window) {
        window.focused.disconnect (window_focused);
        window.unmanaged.disconnect (unmonitor_window);
    }

    private void on_window_created (Meta.Window window) {
        if (window.window_type == Meta.WindowType.NORMAL)
            monitor_window (window);
    }

    private void window_focused (Meta.Window window) {
        var wm_class = window.get_wm_class ();
        var canonicalized_wm_class = wm_class.ascii_down ().delimit (" ", '-');
        var desktop_url = @"$canonicalized_wm_class.desktop";
        var desktop_app = app_cache.lookup_id (desktop_url);

        if (desktop_app == null) {
            desktop_url = @"$(window.get_gtk_application_id ()).desktop";
            desktop_app = app_cache.lookup_id (desktop_url);
        }

        if (desktop_app == null) {
            warning (@"unable to find DesktopAppInfo for $desktop_url");
            return;
        }

        if (desktop_app.get_is_hidden ())
            return;

        var events = new GenericArray<Zeitgeist.Event> ();

        if (last_seen_desktop_url != null) {
            var subject = new Zeitgeist.Subject.full (
                @"application://$last_seen_desktop_url",
                "https://www.semanticdesktop.org/ontologies/2011/10/05/dcon/#activeApplication",
                null,
                null,
                null,
                last_seen_window_title,
                "local");
            var event = new Zeitgeist.Event.full (
                "http://www.zeitgeist-project.com/ontologies/2010/01/27/zg#LeaveEvent",
                "http://www.zeitgeist-project.com/ontologies/2010/01/27/zg#UserActivity",
                "gala-zeitgeist",
                null,
                subject);

            events.add (event);
        }

        last_seen_desktop_url = desktop_url;
        last_seen_window_title = window.get_title ();

        var subject = new Zeitgeist.Subject.full (
            @"application://$desktop_url",
            "https://www.semanticdesktop.org/ontologies/2011/10/05/dcon/#activeApplication",
            null,
            null,
            null,
            last_seen_window_title,
            "local");
        var event = new Zeitgeist.Event.full (
            "http://www.zeitgeist-project.com/ontologies/2010/01/27/zg#AccessEvent",
            "http://www.zeitgeist-project.com/ontologies/2010/01/27/zg#UserActivity",
            "gala-zeitgeist",
            null,
            subject);

        events.add (event);

        /* *INDENT-OFF* */
        Zeitgeist.Log.get_default ().insert_events.begin (events, null,
            (obj, res) => {
                try {
                    Zeitgeist.Log.get_default ().insert_events.end (res);
                } catch (Error err) {
                    warning (err.message);
                }
        });
        /* *INDENT-ON* */
    }

}

public Gala.PluginInfo register_plugin () {
    return Gala.PluginInfo () {
       name = "Zeitgeist",
       author = "Payson Wallach <payson@paysonwallach.com>",
       plugin_type = typeof (Zeitgeist.Plugin),
       provides = Gala.PluginFunction.ADDITION,
       load_priority = Gala.LoadPriority.IMMEDIATE
    };
}

/*
 * Copyright (c) 2020 - Today Goncalo Margalho (https://github.com/devalien)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Goncalo Margalho <g@margalho.info>
 */

public class Workspaces.Dialogs.Preferences : Gtk.Dialog {
    private const int MIN_WIDTH = 300;
    private const int MIN_HEIGHT = 280;

    private GLib.Settings settings;

    public Preferences (bool first_run, Gtk.Window parent) {
        settings = new GLib.Settings (Workspaces.Application.APP_ID);
        transient_for = parent;
        // Window properties
        title = _ ("Preferences");
        set_size_request (MIN_WIDTH, MIN_HEIGHT);
        resizable = false;
        window_position = Gtk.WindowPosition.CENTER;

        add_button (_ ("Close"), Gtk.ResponseType.CLOSE);

        var content_grid = new Gtk.Grid ();
        content_grid.attach (create_general_settings_widgets (first_run), 0, 1, 1, 1);

        var content = get_content_area () as Gtk.Box;

        content.margin = 15;
        content.margin_top = 0;

        content.add (content_grid);
        show_all ();

        response.connect ((source, id) => {
            switch (id) {
            case Gtk.ResponseType.CLOSE :
                destroy ();
                break;
            }
        });
    }

    private Gtk.Grid create_general_settings_widgets (bool first_run) {
        string intro =  _ ("Workspaces can be opened with a quick shortcut so you'll be able to open your projects faster.");

        var intro_label = new Gtk.Label (intro);
        intro_label.halign = Gtk.Align.START;
        intro_label.use_markup = true;
        intro_label.max_width_chars = 50;
        intro_label.wrap = true;

        Gtk.Grid general_grid = new Gtk.Grid ();
        general_grid.margin = 12;
        general_grid.hexpand = true;
        general_grid.column_spacing = 12;
        general_grid.row_spacing = 6;

        var general_header = create_heading (_ ("General Settings"));

        var accel = "";
        string ? accel_path = null;

        CustomShortcutSettings.init ();
        foreach (var shortcut in CustomShortcutSettings.list_custom_shortcuts ()) {
            if (shortcut.command == Workspaces.Application.SHOW_WORKSPACES_CMD) {
                accel = shortcut.shortcut;
                accel_path = shortcut.relocatable_schema;
            }
        }

        var paste_shortcut_label = create_label (_ ("Open Workspaces Shortcut:"));
        var paste_shortcut_entry = new Workspaces.Widgets.ShortcutEntry (accel);
        paste_shortcut_entry.shortcut_changed.connect ((new_shortcut) => {
            if (accel_path != null) {
                CustomShortcutSettings.edit_shortcut (accel_path, new_shortcut);
            }
        });
        if (first_run) {
            general_grid.attach (intro_label, 0, 0, 2, 1);
        }
        general_grid.attach (general_header, 0, 1, 1, 1);

        general_grid.attach (paste_shortcut_label, 0, 2, 1, 1);
        general_grid.attach (paste_shortcut_entry, 1, 2, 1, 1);

        return general_grid;
    }

    private Gtk.Label create_heading (string text) {
        var label = new Gtk.Label (text);
        label.get_style_context ().add_class ("h4");
        label.halign = Gtk.Align.START;

        return label;
    }

    private Gtk.Label create_label (string text) {
        var label = new Gtk.Label (text);
        label.hexpand = true;
        label.halign = Gtk.Align.START;
        label.margin_start = 20;

        return label;
    }
}
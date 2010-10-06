/* -*- mode: java; c-file-style: "gnu"; indent-tabs-mode: nil; -*- */

using Gtk;
using Gee;

class ProcessHistory {
  public long pid;
  public ArrayList<string> lines;
}

class StraceDatabase {
  private Gee.Map<long, ProcessHistory> processes;
  private GLib.Regex strace_regexp;

  public StraceDatabase() {
    processes = new Gee.HashMap<long, ProcessHistory>();
    try {
      strace_regexp = new GLib.Regex("^([0-9]+) (.*)$");
    } catch (GLib.Error e) {
    }
  } 
  
  public void parse(string filename) throws GLib.Error {
    var file = GLib.File.new_for_path(filename);
    var input = new GLib.DataInputStream(file.read(null));
    string line;
    while ((line = input.read_line(null, null)) != null) {
      GLib.MatchInfo match;
      if (!strace_regexp.match(line, 0, out match))
        continue;
      string? pid_str = match.fetch(1);
      string? strace_data = match.fetch(2);
      if (pid_str == null)
        continue;
      if (strace_data == null)
        continue;
      long pid = pid_str.to_long();

      ProcessHistory p;
      if (!processes.has_key(pid)) {
        p = new ProcessHistory();
        p.pid = pid;
        p.lines = new ArrayList<string>();
        processes.set(pid, p);
      } else {
        p = processes.get(pid);
      }
      p.lines.add(strace_data);
    }
  }

  public Gee.Collection<ProcessHistory> getProcesses() {
    return processes.values;
  }
}

class StraceNotebook : Gtk.VBox {
  private Gtk.Notebook notebook;
  private StraceDatabase database;
  
  public StraceNotebook() {
    notebook = new Gtk.Notebook();
    this.add(notebook);
    database = new StraceDatabase();
  }

  private Gtk.TextBuffer buffer_for_history(ProcessHistory p) {
    var buf = new Gtk.TextBuffer(null);
    foreach (string line in p.lines) {
      buf.insert_at_cursor(line, -1);
      buf.insert_at_cursor("\n", -1);
    }
    return buf;
  }

  private Gtk.Widget view_for_history(ProcessHistory p) {
    var scroll = new Gtk.ScrolledWindow(null, null);
    var text_view = new Gtk.TextView.with_buffer(buffer_for_history(p));
    scroll.add(text_view);
    return scroll;
  }

  public void parse(string filename) throws GLib.Error {
    database.parse(filename);
    
    foreach (ProcessHistory p in database.getProcesses()) {
      var view = view_for_history(p);
      var label = new Gtk.Label("PID %ld".printf(p.pid));
      notebook.append_page(view, label);
    }
  }
}

class StraceNotebookApp : GLib.Object {
  public static int main(string[] args) {
    Gtk.init (ref args);
    var filename = args[1];
    var window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
    window.set_default_size(640, 480);
    window.destroy.connect(Gtk.main_quit);

    var notebook = new StraceNotebook();
    try {
      notebook.parse(filename);
    } catch (GLib.Error e) {
      GLib.printerr("Failed to parse: %s", e.message);
    }

    window.add(notebook);

    window.show_all();
    Gtk.main(); 
    return 0;
  }
}

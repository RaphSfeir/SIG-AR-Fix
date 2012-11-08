# Function to export the current model with Sig-Ar info
def sigar_export()
  # Initilization of the window
  export_width = 825
  export_height = 600
  c = Sketchup.active_model.active_view.center
  dlgExport = UI::WebDialog.new("SIG-AR - Export your model", false, "ShowSigArFix_Export", export_width, export_height, c[0]-export_width/2, c[1]-export_height/2, true);
  dlgExport.set_file File.dirname(__FILE__)+"/html/export.html"

  # Will center the screen
  dlgExport.add_action_callback("move") { |d, a|
    xy, wh = a.split(":")
  
    x, y = xy.split(",")
    x = x.to_i
    y = y.to_i
  
    w, h = wh.split(",")
    w = w.to_i
    h = h.to_i
  
    d.set_position((x - w)/2, (y - h)/2)
  }

  dlgExport.min_width = export_width
  dlgExport.min_height = export_height
  dlgExport.max_width = export_width
  dlgExport.max_height = export_height
  # Show the window
  dlgExport.show
end
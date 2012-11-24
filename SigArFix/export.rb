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
  # Add callback to test the connection to the Database
  dlgExport.add_action_callback("sigar_export_testConnection") {|dialog, params|
     UI.messagebox("You called sigar_export_testConnection with: " + params.to_s)
   }
  # Add callback to export the model to the Database
  dlgExport.add_action_callback("sigar_export_exportModel") {|dialog, params|
     UI.messagebox("You called sigar_export_exportModel with: " + params.to_s)
   }
  # Add callback to close the dialog
  dlgExport.add_action_callback("sigar_export_close") {|dialog, params|
     dlgExport.close
   }
  # Add callback to get filename and dir
  dlgExport.add_action_callback("sigar_export_getfilenamedir") {|dialog, params|
     model = Sketchup.active_model
     js_command = "export_setFileNameDir("+ model.path + model.name + ")"
     dlgExport.execute_script(js_command)
   }
  # Show the window
  model = Sketchup.active_model
  if (! model)
    UI.messagebox "Please first open or create a model"
  else
    if (model.path == '')
      UI.messagebox "Please first save your model"
    else
      dlgExport.show
    end
  end
end
def sigar_export()
  dlgExport = UI::WebDialog.new("Show Sketchup.com", true,
     "ShowSketchUpDotCom", 739, 641, 150, 150, true);
   dlgExport.set_file "html/export.html"
   dlgExport.show
end
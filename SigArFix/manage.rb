def sigar_manage()
  dlg = UI::WebDialog.new("Show Sketchup.com", true, "ShowSketchUpDotCom", 850, 650, 0, 0, true);
  dlg.set_file File.dirname(__FILE__) + "/html/manage.html"
  dlg.show
end
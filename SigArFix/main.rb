# This script and the entire SIG-AR-Fix folder should be located in the Plugins folder of Sketchup.
# SketchUp looks in its Plugins folder for ruby scripts every time it starts.
# 1. If you haven't already done so, install SketchUp or SketchUp Pro.
# 2. PC folks: Use Windows Explorer to locate your Plugins folder. It should be something like... 
#        c:\Program Files\Google\Google SketchUp [n]\Plugins
#    Mac folks: Use Finder. It should be something like... 
#        /Library/Application Support/Google SketchUp [n]/plugins 
#        ...or like... 
#        /Library/Application Support/Google SketchUp [n]/SketchUp/plugins
# 3. Paste the SIG-AR-Fix folder in the correct location, then restart SketchUp
# Authors :
#    ALAY-EDDINE Maxime
#    SFEIR Raphael
# Done for SIG-AR Project, Ecole Centrale, Nantes (France)

# Definition of basics functions for the interface
load "SigArFix/export.rb"
load "SigArFix/manage.rb"
load "SigArFix/about.rb"

# Append functions to the interface
sig_ar_plugins_menu = UI.menu("Plugins")
sig_ar_plugins_submenu = sig_ar_plugins_menu.add_submenu("SIG-AR")
sig_ar_plugins_submenu_itemExport = sig_ar_plugins_submenu.add_item("Export for SIG-AR") { sigar_export }
sig_ar_plugins_submenu_itemManage = sig_ar_plugins_submenu.add_item("Manage models...") { sigar_manage }
sig_ar_plugins_submenu_itemManage = sig_ar_plugins_submenu.add_item("About") { sigar_about }
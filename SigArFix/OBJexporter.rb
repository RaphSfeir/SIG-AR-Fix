=begin
###########################################################################
TIG (c) 2010/2011
All Rights Reserved.
THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES,INCLUDING,WITHOUT LIMITATION,THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
###########################################################################
OBJexporter.rb
###########################################################################
Usage: menu File > 'OBJexporter...'
It Exports the Model in OBJ Format with an associated MTL file and a folder 
of Textures if appropriate.
The files sub-folder are put into the Model's folder.
The files use the SKP's name.
Everything that is not Hidden and that is on visible Layers is Exported.
The Units are always in 'meters'.
All Exported Faces are Triangulated,
###########################################################################
To do: Options Dialog... Units, Triangulation, Model/Selection
###########################################################################
Donations:
  By Paypal.com to info @ revitrev.org
###########################################################################
Version:
20101216 First issue.
###########################################################################
=end
###
require 'sketchup.rb'
###

class Sketchup::Image
	def definition
		self.model.definitions.each{|d|
          return d if d.image? && d.instances.include?(self)
        }
        return nil
	end#def

	def transformation
		origin=self.origin
		axes=self.normal.axes
		tr=Geom::Transformation.axes(ORIGIN, axes.at(0), axes.at(1), axes.at(2))
		tr=tr*Geom::Transformation.rotation(ORIGIN, Z_AXIS, self.zrotation)
		tr=(tr*Geom::Transformation.scaling(ORIGIN, self.width/self.pixelwidth, self.height/self.pixelheight, 1)).to_a
		tr[12]=origin.x
		tr[13]=origin.y
		tr[14]=origin.z
		return Geom::Transformation.new(tr)
	end#def

	def transformation=(tr)
		self.transform!(self.transformation.inverse*tr)
	end
end# Image class

###########

class OBJexporter

    def initialize()
        @model=Sketchup.active_model
        path=@model.path.tr("\\", "/")
        if not path or path==""
            UI.messagebox("OBJExporter:\n\nSave the SKP before Exporting it as OBJ\n")
            return nil
        end#if
        @project_path=File.dirname(path)
        @title=@model.title
        @skpName=@title
        @sel=@model.selection
        ### get settings etc...
        self.export()
        ###
    end

    def export()
        Sketchup.set_status_text("OBJExporter: Exporting OBJ & MTL Files...")
		@obj_="true"
        @obj_name=@skpName
        @obj_name=@obj_name+".obj"
        @obj_filepath=File.join(@project_path, @obj_name)
        @mtllib=@skpName+".mtl"
        @mtl_file=File.join(@project_path, @mtllib)
		@textures_name=@skpName+"_Textures"
        @textures_path=File.join(@project_path, @textures_name)
		@v_counter=0
		@obj_list=[]
		@used_materials=[]
        Sketchup.set_status_text("OBJexporter: Exporting OBJ & MTL Files...")
		starttime=Time.now.to_f
        self.export_start()
		endtime=(((Time.now.to_f - starttime)*10000).to_i/10000.0).to_f.to_s
		Sketchup.set_status_text("OBJexporter: OBJ & MTL Files Completed in #{endtime} seconds")
	end
    
    def export_start()
		@obj_file=File.new(@obj_filepath, "w")
        @obj_file.puts "# Alias Wavefront OBJ File Exported from SketchUp"
        @obj_file.puts "# with OBJexporter (c) 2010/2011 TIG"
        @obj_file.puts "# Units = meters"
        @obj_file.puts ""
		@obj_file.puts "mtllib #{@mtllib}"
        @obj_file.puts ""
		Sketchup.set_status_text("OBJexporter: Making OBJ File...")
		self.export_obj()
		@obj_file.close if @obj_file
        Sketchup.set_status_text("OBJexporter: Exporting Textures...")
		self.export_textures()
        Sketchup.set_status_text("OBJexporter: Making MTL File...")
		self.export_mtl_material()
	end

	def export_obj()
        @img_mats=[]
		title=@title
		ents=Sketchup.active_model.entities.to_a
		objname=title+"_Main"
		Sketchup.set_status_text("OBJexporter: Making Meshes...")
        faces=ents.find_all{|e|e.class==Sketchup::Face}
	    if faces[0]
			@obj_list << [objname, nil, "Default_Material"] 
		    self.export_entities(faces, objname)
		end#if
		Sketchup.set_status_text("OBJexporter: Meshes Completed.")
		tr=Geom::Transformation.axes( (Geom::Point3d.new 0,0,0),(Geom::Vector3d.new(1,0,0)),(Geom::Vector3d.new(0,1,0)),(Geom::Vector3d.new(0,0,1)) )
        ###
	    ents.find_all{|e|e.class==Sketchup::Group}.each{|gp| self.export_group(gp, title, tr) }
	    ents.find_all{|e|e.class==Sketchup::ComponentInstance}.each{|ci| self.export_component_instance(ci, title, tr) }
        ents.find_all{|e|e.class==Sketchup::Image}.each{|ci| self.export_image(ci, title, tr) }
        ###
	end

	def export_group(gp, title="", tr=Geom::Transformation.new, mat=nil)
		return if gp.hidden? == true or gp.layer.visible? == false
		ot=tr * gp.transformation
		defmat=mat if mat and gp.material == nil
		defmat=gp.material if gp.material
		@used_materials << defmat
		id=gp.entityID
		name="#{id}"
        name=name + "-" + gp.name if gp.name or gp.name=""
		name.gsub!(/[^\-_0-9A-Za-z]/, "_")
		objname=title + "_g_" + name
		@matname="Default_Material"
        if defmat
			@matname=defmat.display_name.gsub(/[^\-_0-9A-Za-z]/, '_')
		end
		if gp.entities.find{|e|e.class==Sketchup::Face}
			self.export_entities(gp.entities.find_all{|e|e.class==Sketchup::Face}, objname, ot, defmat) if @obj_ or @obj_list.find{|ol| ol[0] == objname } == nil
			@obj_list << [objname, ot, @matname]
		end
        ###
		gp.entities.find_all{|e| e.class==Sketchup::Group}.each{|f| self.export_group(f, title, ot, defmat) }
	    gp.entities.find_all{|e| e.class==Sketchup::ComponentInstance}.each{|f| self.export_component_instance(f, title, ot, defmat) }
        gp.entities.find_all{|e|e.class==Sketchup::Image}.each{|f| self.export_image(f, title, ot) }
        ###
	end
     
	def export_component_instance(ci, title="", tr=Geom::Transformation.new, mat=nil)
		return if ci.hidden? or not ci.layer.visible?
		ot=tr * ci.transformation
		defmat=mat if mat and ci.material == nil
		defmat=ci.material if ci.material
		@used_materials << defmat
		id=ci.entityID
		name=ci.definition.name
		name="#{id}" if name.length == 0
		name.gsub!(/[^\-_0-9A-Za-z]/, "_")
		objname=title + "_c_" + name
		@matname="Default_Material"
        if defmat
			@matname=defmat.display_name.gsub(/[^\-_0-9A-Za-z]/, '_')
		end
		if ci.definition.entities.find{|e| e.class==Sketchup::Face }
			self.export_entities(ci.definition.entities.find_all{|e|e.class==Sketchup::Face}, objname, ot, defmat) if @obj_ or @obj_list.find{|ol| ol[0] == objname } == nil
			@obj_list << [objname, ot, @matname]
		end
		(ci.definition.entities.find_all{|e| e.class==Sketchup::Group}).each{|f| self.export_group(f, title, ot, defmat) }
	    (ci.definition.entities.find_all{|e| e.class==Sketchup::ComponentInstance}).each{|f| self.export_component_instance(f, title, ot, defmat) }
        (ci.definition.entities.find_all{|e| e.class==Sketchup::Image}).each{|f| self.export_image(f, title, ot) }
	end
    
    def export_image(img, title="", tr=Geom::Transformation.new)
		return if img.hidden? == true or img.layer.visible? == false
        defn=img.definition ###v09
        return if not defn
        face=nil
        defn.entities.each{|e|
          if e.class==Sketchup::Face
            face=e
            break
          end#if
        }
        return if not face
		ot=tr * img.transformation ###v09
		defmat=face.material
		@used_materials << defmat
		id=img.entityID
		name="#{id}"
		name.gsub!(/[^\-_0-9A-Za-z]/, "_")
		objname=title + "_i_" + name
		@matname="Image_Material" ### should never get used !
        if defmat and defmat.name
            @matname=defmat.name.gsub(/[^\-_0-9A-Za-z]/, '_')
		end
        @img_mats<< defmat
        self.export_entities([face], objname, ot, defmat) if @obj_ or @obj_list.find{|ol| ol[0] == objname } == nil
        @obj_list << [objname, ot, @matname]
        ###
	end

	def export_entities(all_faces=[], objname="", tr=nil, defmat=nil)
        @saved_names=[]
        mats = [nil] + Sketchup.active_model.materials.to_a + @img_mats
		mats.each{|mat|
			faces=all_faces.find_all{|face|face.material==mat}
			if faces[0]
                @used_materials << mat
            else
                next
            end#if
            ###
            vs=[]
			nos=[]
			uvs=[]
			meshes=[]
			Sketchup.set_status_text("OBJexporter: Processing Faces...")
            ###
			faces.each{|face|
				next if face.hidden? or not face.layer.visible?
				mesh=face.mesh(5)###7=backs too
				next if not mesh
                f_uvs=(1..mesh.count_points).map{|i|mesh.uv_at(i,1)}####1=front
                f_vs=[]
                f_vs=(1..mesh.count_points).map{|i|mesh.points[i-1]}
				f_nos=[]
                f_nos=(1..mesh.count_points).map{|i|mesh.normal_at(i)}
                f_vcount=1; f_vcount=vs.length + 1 if vs[0]
				meshes.concat(mesh.polygons.map{|p| [p.map{|px|(f_vs.index(mesh.points[(px.abs-1)]) + f_vcount)}] })
                ###
                vs.concat(f_vs) if f_vs
				uvs.concat(f_uvs) if f_uvs
				nos.concat(f_nos) if f_nos
                ###
			}#faces.each
            ###
            @vs=vs
			@nos=nos
			@uvs=uvs
			@meshes=meshes
            mat=defmat if not mat
			self.export_obj_file(objname, tr, mat)
            ######################################
		}#mats.each
	end
    
    def flattenUVQ(uvq) ### UNUSED ???
        return Geom::Point3d.new((uvq.x/uvq.z), (uvq.y/uvq.z), 1.0)
    end#flattenUVQ

	def export_obj_file(objname="", tr=nil, mat=nil)
		Sketchup.set_status_text("OBJexporter: Processing Object File...")
		ot=Geom::Transformation.new
		ot=tr if tr 
        if mat
			mat_name=mat.display_name.gsub(/ /, '_').gsub(/[^_0-9A-Za-z]/, '')
            saved_name=File.basename(mat_name)
			saved_name_uniq=self.make_name_unique(@saved_names, saved_name)
			@saved_names << saved_name_uniq
            matname=saved_name_uniq
        else
            matname="Default_Material"
		end
		return if @meshes == nil
		objname=objname.gsub(/ /, '_').gsub(/[^_0-9A-Za-z]/, '')
		if @meshes.length != 0 and @vs.length != 0
			if matname
				@obj_file.puts "g #{objname}-#{matname}"
				@obj_file.puts "usemtl #{matname}"
			else
				@obj_file.puts "g #{objname}-Default_Material"
				@obj_file.puts "usemtl Default_Material"
				matname="Default_Material"
			end#if
		    @v_counter=0 if not @v_counter
			@vs.each{|v|
				v=ot * v
				@obj_file.puts "v #{"%.6f" % v.x.to_m.to_f} #{"%.6f" % v.z.to_m.to_f} #{"%.6f" % (-v.y.to_m.to_f)}"
			}
			@nos.each{|vnor|
				nor=ot * vnor
				nor.normalize!
				@obj_file.puts "vn #{"%.6f" % (nor.x)} #{"%.6f" % (nor.z)} #{"%.6f" % (-nor.y)}"
			}
			@uvs.each{|uv|
				@obj_file.puts "vt #{"%.6f" % (uv.x)} #{"%.6f" % (uv.y)}"
			}
			@meshes.each{|mesh|
				f_str="f"
				mesh.each do |pg|
					pg.each{|j|
						k=j+@v_counter
						f_str += " #{k}/#{k}/#{k}"
					}
					@obj_file.puts f_str
				end
			}
			@obj_file.puts ""
			@v_counter += @vs.length if @vs[0]
		end
		@meshes=nil
		@uvs=nil
		@nos=nil
		@vts=nil
        Sketchup.set_status_text("OBJexporter: Object Completed.")
	end
    
	def make_texture_folder()
        begin
          Dir.mkdir(@textures_path) if not File.exist?(@textures_path)
        rescue
          UI.messagebox(@textures_path+" ??")
        end
	end
    
	def export_textures()
        Sketchup.set_status_text("OBJexporter: Exporting Textures...")
		self.make_texture_folder()
		temp_group=Sketchup.active_model.active_entities.add_group()
		saved_names=[]
        tw=Sketchup.create_texture_writer
        mats=Sketchup.active_model.materials.to_a
        (mats + @img_mats).each{|mat|
			if mat and mat.texture
                next if not @used_materials.include?(mat)
                ### don't export unused / invisible materials for speed
				temp_group.material=mat
                mat_texture_file=mat.texture.filename.tr("\\", "/")
                mat_texture_extn=File.extname(mat_texture_file)
                mat_base_bname=File.basename(mat_texture_file)
                mat_texture_basename=File.basename(mat_texture_file, mat_texture_extn)
                mat_texture_name=mat.display_name.gsub(/ /, '_').gsub(/[^_0-9A-Za-z]/, '') + mat_texture_extn
                saved_name=mat_texture_name
				saved_name_uniq=self.make_name_unique(saved_names, saved_name)
				saved_names << saved_name_uniq
                tpath=File.join(@textures_path, saved_name_uniq)
                tw.load(temp_group)
                tw.write(temp_group, tpath)
                ###
			end#if
		}
		temp_group.erase! if temp_group.valid?
		Sketchup.set_status_text("OBJexporter: Textures Exported.")
	end

    
	def export_mtl_material()
        Sketchup.set_status_text("OBJexporter: Making MTL File...")
        ffcol=@model.rendering_options["FaceFrontColor"]
		mtl_file=File.new(@mtl_file,"w")
        mtl_file.puts "# Alias Wavefront MTL File Exported from SketchUp"
        mtl_file.puts "# with OBJexporter (c) 2010/2011 TIG"
        mtl_file.puts "# Made for '"+@obj_name+"'"
        mtl_file.puts ""
		mtl_file.puts "newmtl Default_Material"
		mtl_file.puts "Ka 0.000000 0.000000 0.000000"
		mtl_file.puts "Kd " + ffcol.to_a[0..2].collect{|c| "%.6f" % ((c.to_f/255)) }.join(" ")
		mtl_file.puts "Ks 0.000000 0.000000 0.000000"
        mtl_file.puts "d 1.000000"
		mtl_file.puts ""
        saved_names=[]
		@used_materials.uniq!
		@used_materials.each{|mat|
			next if not mat
            mat_name=mat.display_name.gsub(/ /, '_').gsub(/[^_0-9A-Za-z]/, '')
            saved_name=File.basename(mat_name)
			saved_name_uniq=self.make_name_unique(saved_names, saved_name)
			saved_names << saved_name_uniq
            matname=saved_name_uniq
			if mat and mat.texture
                texture_extn=File.extname(mat.texture.filename)
				texture_path=File.join(@textures_name, matname + texture_extn)
			end
			mtl_file.puts "newmtl #{matname}"
			if not mat.use_alpha?
				mtl_file.puts "Ka 0.000000 0.000000 0.000000"
				mtl_file.puts "Kd " + mat.color.to_a[0..2].collect{|c| "%.6f" % ((c.to_f/255)) }.join(" ")
				mtl_file.puts "Ks 0.000000 0.000000 0.000000"
				mtl_file.puts "d 1.000000"
				mtl_file.puts "map_Kd #{texture_path}" if texture_path
			else ### it's transparent
				mtl_file.puts "Ka 0.000000 0.000000 0.000000"
				mtl_file.puts "Kd " + mat.color.to_a[0..2].collect{|c| "%.6f" % ((c.to_f/255)) }.join(" ")
				mtl_file.puts "Ks 0.000000 0.000000 0.000000"
				mtl_file.puts "d #{"%.6f" % mat.alpha }"### it's NOT (1 - mat.alpha) !!!
				mtl_file.puts "map_Kd #{texture_path}" if texture_path
			end#if
            mtl_file.puts ""
		}
		mtl_file.puts "#EOF"
		mtl_file.flush
		mtl_file.close
        Sketchup.set_status_text("OBJexporter: MTL File Completed.")
	end
    
	def make_name_unique(saved_names=[], saved_name="")
		if saved_names.include?(saved_name)
			counter=1
			while counter < 10000
				new_name=File.basename(saved_name, ".*") + counter.to_s + File.extname(saved_name)
				return new_name if not saved_names.include?(new_name)
				counter += 1
			end
		end
		return saved_name
	end
############## end of exporter code #########################


end#class OBJexporter ##########################################################
###

### make shortcut to tool #################################################
def objexporter()
  Sketchup.active_model.select_tool(OBJexporter.new())
end#def octane
###


### add menu item etc #####################################################
if not file_loaded?(File.basename(__FILE__))
  UI.menu("File").add_item("OBJexporter..."){OBJexporter.new()}
end#if
file_loaded(File.basename(__FILE__))
###
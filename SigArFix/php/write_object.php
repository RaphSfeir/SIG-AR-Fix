<?php

require_once "interface.php";
try {
    $dbh = new PDO($dsn, $user, $pass);
	var_dump($_FILES);
	$file_object = $_FILES['file'];
	$file_mtl = $_FILES['mtl'];
	$file_picture = $_FILES['picture'];
	
	//Treatment object file
	$modelname = $file_object['name'];
	$scenename = $_POST['modelname']; // Pas de mysql_escape_string avec PDO pour Postgresql. S�curit� � voir plus tard.
	$authorid = 1; //mysql_escape_string($_POST['authorid']);   ########################################## TO CHANGE #######################
	$categoryid = 1; // mysql_escape_string($_POST['categoryid']);
	$description = $_POST['description'];
	$gps_longitude = $_POST['longitude'];
	$gps_latitude = $_POST['latitude'];
	$gps_altitude = $_POST['altitude'];

	//Get obj content
	$tmpname = $file_object['tmp_name'];
	$fp = fopen($tmpname, 'r');
	$modelcontent = fread($fp, filesize($tmpname));
	$modelcontent = pg_escape_bytea($modelcontent);
	fclose($fp);

	//Get mtl content
	$mtlname = $file_mtl['name'];
	$tmpname = $file_mtl['tmp_name'];
	$fp = fopen($tmpname, 'r');
	$mtlcontent = fread($fp, filesize($tmpname));
	$mtlcontent = pg_escape_bytea($mtlcontent);
	fclose($fp);

	//Get picture content
	$tmpname = $file_picture['tmp_name'];
	$fp = fopen($tmpname, 'r');
	$picturecontent = fread($fp, filesize($tmpname));
	$picturecontent = pg_escape_bytea($picturecontent);
	fclose($fp);
	
	//Get textures content
	if(array_key_exists("textures", $_FILES)) {
		foreach ($_FILES['textures'] as $file_texture) {
			$tmpname = $file_texture['tmp_name'];
	    	$fp = fopen($tmpname, 'r');
			$texturesContentTmp = fread($fp, filesize($tmpname));
			$texturesContent[] = pg_escape_bytea($texturesContentTmp);
			$texturesNames[] = $file_texture['name'];
			fclose($fp);
		}
	}
	
	//Store object
	$request_object = "INSERT INTO object3d (
								'name_object',
								'file_obj',
								'name_mtl',
								'file_mtl',
								'date_creation',
								'id_author'
								)
							VALUES (
								'".$modelname."',
								'".$modelcontent."',
								'".$mtlname."',
								'".$mtlcontent."',
								'".date("Y-m-d H:i:s")."',
								'".$authorid."'
								)
							RETURNING id_object3d;";
	echo "Executing object upload...\n";
	$req = $dbh->prepare($request_object);
	$req->execute();
	$result_object = $req->fetch(PDO::FETCH_ASSOC);
	$id_object = $result_object["id_object3d"];
	
	//Store icon
	$request_picture = "INSERT INTO icon (
								'file_icon'
								)
							VALUES (
								'".$picturecontent."'
								)
							RETURNING id_icon;";
	$req = $dbh->prepare($request_picture);
	echo "Executing icon upload...\n";
	$req->execute();
	$result_picture = $req->fetch(PDO::FETCH_ASSOC);
	$id_icon = $result_picture["id_icon"];

	//Store scene
	$request_scene = "INSERT INTO scene(
								'name_scene',
								'description',
								'id_category',
								'id_icon',
								'activation',
								'gps_longitude',
								'gps_latitude',
								'gps_altitude',
								'id_author',
								'date_creation',
								'id_object3d',
								'translation_x',
								'translation_y',
								'translation_z',
								'rotation_x',
								'rotation_y',
								'rotation_z',
								'scale_x',
								'scale_y',
								'scale_z'
								)
							VALUES (
								'".$scenename."',
								'".$description."',
								".$categoryid.",
								".$id_icon.",
								false,
								".$gps_longitude.",
								".$gps_latitude.",
								".$gps_altitude.",
								".$authorid.",
								'".date("Y-m-d H:i:s")."',
								'".$id_object."',
								0,
								0,
								0,
								0,
								0,
								0,
								1,
								1,
								1
								)
							RETURNING id_scene;";
	$req = $dbh->prepare($request_scene);
	echo "Executing scene upload...\n";
	$req->execute();
	$result_scene = $req->fetch(PDO::FETCH_ASSOC);
	$result_scene = $result_scene["id_scene"];
	
	if(array_key_exists("textures", $_FILES)) {
		//Store textures
		for($j=0;$j<count($texturesContent);$j++) {
			$request_texture = "INSERT INTO texture (
									'name_texture',
									'file_texture',
									'id_object3d'
									)
								VALUES (
									'".$texturesNames[$j]."',
									'".$texturesContent[$j]."',
									".$id_object."
									);";
			$req = $dbh->prepare($request_texture);
			echo "Executing texture upload...\n";
			$req->execute();	
		}
	}
	echo "Done!";
    $dbh = null;
} 
        catch (PDOException $e) {
        echo json_encode(array("error" => $e->getMessage()));
    die();
}
?>
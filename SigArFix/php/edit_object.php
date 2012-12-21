<?php

require_once "interface.php";

$id_object = $_POST['id_object'];
$id_scene = $_POST['id_scene'];

$longitude = $_POST['longitude'];
$latitude = $_POST['latitude'];
$altitude = $_POST['altitude'];
$rotation_x = $_POST['rotation_x'];
$rotation_y = $_POST['rotation_y'];
$rotation_z = $_POST['rotation_z'];

$name_scene = addslashes($_POST['filename']);
$name_object = addslashes($_POST['name']);

$id_auteur = 1;
//$id_auteur = base64_decode($_GET['idauth']);

try {
    $dbh = new PDO($dsn, $user, $pass);
	
	$query_up_scene = "UPDATE scene SET gps_altitude = '".$altitude."', gps_longitude = '".$longitude."', gps_latitude = '".$latitude."', name_scene = '".$name_scene."', rotation_x = '".$rotation_x."', rotation_y = '".$rotation_y."', rotation_z = '".$rotation_z."' WHERE id_scene = ".$id_scene."";
	$query_up_obj = "UPDATE object3d SET name_object = '".$name_object."' WHERE id_object3d = '".$id_object."'";

	
	$qry = $dbh->prepare($query_up_scene);    
	$qry->execute();
     
	$qry = $dbh->prepare($query_up_obj);    
	$qry->execute();

    $dbh = null;
} 
        catch (PDOException $e) {
        echo json_encode(array("error" => $e->getMessage()));
    die();
}

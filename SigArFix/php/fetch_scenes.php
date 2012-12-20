<?php

require_once "interface.php";
$method = $_SERVER['REQUEST_METHOD'];
header("Access-Control-Allow-Origin: *");
header('Content-type: application/json');
$id_auteur = 1;
//$id_auteur = base64_decode($_GET['idauth']);
try {
	$dbh = new PDO($dsn, $user, $pass);
	
	$qry = $dbh->prepare("select A.id_scene, A.rotation_x, A.rotation_y, A.rotation_z, A.gps_longitude, A.gps_altitude, A.gps_latitude, A.name_scene, B.name_object, B.date_creation, B.id_author from scene A, object3d B where A.id_author = ".$id_auteur." AND A.id_object3d = B.id_object3d;");    

	$qry->execute();
	$objets3d = $qry->fetchAll();
	//print_r($objets3d);echo "<br />";
	echo json_encode($objets3d);
	$dbh = null;
} 
        catch (PDOException $e) {
        echo json_encode(array("error" => $e->getMessage()));
    die();
}

<?php

require_once "interface.php";
$id_auteur = 1;
//$id_auteur = base64_decode($_GET['idauth']);
try {
    $dbh = new PDO($dsn, $user, $pass);
    $qry = $dbh->prepare("select nom_objet, date_creation, id_auteur from objet3d where id_auteur = ".$id_auteur.";");
        $qry->execute();
         
        $objets3d = $qry->fetchAll();
        echo json_encode($objets3d);
    $dbh = null;
} 
        catch (PDOException $e) {
        echo json_encode(array("error" => $e->getMessage()));
    die();
}
?>
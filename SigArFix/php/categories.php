<?php

require_once "interface.php";
$method = $_SERVER['REQUEST_METHOD'];
header("Access-Control-Allow-Origin: *");
try {
    $dbh = new PDO($dsn, $user, $pass);
    switch ($method) {
      case 'GET':
        header('Content-type: application/json');
        $qry = $dbh->prepare("select id_category, name_category from category;");
        $qry->execute();
        $categories = $qry->fetchAll();
        echo json_encode($categories);
        break;
      case 'POST':
        header('Content-type: text/plain');
        if(is_null($_POST["category_name"])) {
            echo "Impossible de r&eacute;cup&eacute;rer le nom de la cat&eacute;gorie."
        }
        else {
          echo "Tentative d'insertion...";
          $qry = $dbh->prepare("insert into category(name_category) values ('".$_POST["category_name"]."');");
          $qry->execute();
          echo "Nouvelle cat&eacute;gorie cr&eacute;e !"
        }
        break;
      default:
      break;
    }
    $dbh = null;
}
    catch (PDOException $e) {
        echo json_encode(array("error" => $e->getMessage()));
    die();
}
?>

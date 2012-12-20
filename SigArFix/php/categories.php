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
            echo "Can't get the name."
        }
        else {
          echo "Attempting to add category...";
          $qry = $dbh->prepare("insert into category(name_category) values ('".$_POST["category_name"]."');");
          $qry->execute();
          echo "New category added !"
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

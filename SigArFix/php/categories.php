<?php

require_once "interface.php";
$method = $_SERVER['REQUEST_METHOD'];
header("Access-Control-Allow-Origin: *");
header('Content-type: application/json');
try {
    $dbh = new PDO($dsn, $user, $pass);
    switch ($method) {
      case 'GET':
        $qry = $dbh->prepare("select id_category, name_category from category;");
        $qry->execute();
        $categories = $qry->fetchAll();
        echo json_encode($categories);
        break;
      case 'POST':
        var_dump($_POST);
        if(is_null($_POST["category_name"])) {
          echo json_encode(array('state' => 0));
        }
        else {
          $qry = $dbh->prepare("insert into category(name_category) values ('".$_POST["category_name"]."');");
          $qry->execute();
          echo json_encode(array('state' => $qry->rowCount(), 'value' => $_POST["category_name"]));
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
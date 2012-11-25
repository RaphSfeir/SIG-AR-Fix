<?php

require_once "interface.php";
$method = $_SERVER['REQUEST_METHOD'];
header("Access-Control-Allow-Origin: *");
header('Content-type: application/json');
try {
    $dbh = new PDO($dsn, $user, $pass);
    switch ($method) {
      case 'GET':
        $qry = $dbh->prepare("select id_person, name_person, firstname_person from person;");
        $qry->execute();
        $authors = $qry->fetchAll();
        echo json_encode($authors);
        break;
      case 'POST':
        var_dump($_POST);
        if(is_null($_POST["author_name"]) || is_null($_POST["author_firstname"])) {
          echo json_encode(array('state' => 0));
        }
        else {
          $qry = $dbh->prepare("insert into person(name_person, firstname_person) values ('".$_POST["author_name"]."', '".$_POST["author_firstname"]."');");
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
<?php

require_once "interface.php";
$method = $_SERVER['REQUEST_METHOD'];
header("Access-Control-Allow-Origin: *");
try {
    $dbh = new PDO($dsn, $user, $pass);
    switch ($method) {
      case 'GET':
        header('Content-type: application/json');
        $qry = $dbh->prepare("select id_person, name_person, firstname_person from person;");
        $qry->execute();
        $authors = $qry->fetchAll();
        echo json_encode($authors);
        break;
      case 'POST':
        header('Content-type: text/plain');
        if(is_null($_POST["author_name"]) || is_null($_POST["author_firstname"])) {
          echo "Cannot get the name and the firstname !";
        }
        else {
          echo "Trying insertion...";
          $qry = $dbh->prepare("insert into person(name_person, firstname_person) values ('".$_POST["author_name"]."', '".$_POST["author_firstname"]."');");
          $qry->execute();
          echo "New author added.";
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

<?php
$host = "localhost"; //database host server
$db = "drawing_players"; //database name
$user = "Tanmay_Bakshi"; //database user
$pass = "__"; //password

$connection = mysql_connect($host, $user, $pass);

//Check to see if we can connect to the server
if(!$connection)
{
    die("Database server connection failed.");  
}
else
{
    //Attempt to select the database
    $dbconnect = mysql_select_db("drawing_players", $connection);

    //Check to see if we could select the database
    if(!$dbconnect)
    {
        die("Unable to connect to the specified database!");
    }
    else
    {
    	mysql_query("DELETE FROM `drawing_players`.`players` WHERE `pid`='" . $_GET['pid'] . "'", $connection);
        $query = "INSERT INTO `drawing_players`.`players` (`pid`, `x`, `y`) VALUES ('" . $_GET['pid'] . "', '" . $_GET['x'] . "', '" . $_GET['y'] . "');";
        $resultset = mysql_query($query, $connection);

        echo "Successfully added ";
        echo $query;

    }


}


?>

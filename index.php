<html>
<head>
</head>
<body>
 <div>
 <h1>UPLOAD ANY FILE</h1>
 <form action="" method="post" enctype="multipart/form-data">
    <input type="file" name="ufile">
<br><input type="submit" value="upload"> 
 </form>
 </div>
 <?php
 $filename=$_FILES["ufile"]["name"];
 $tempname=$_FILES["ufile"]["tmp_name"];
 $folder="./".$filename;
 $ok=move_uploaded_file($tempname,$folder);
 //echo $folder;echo $tempname;
 if($ok)
 {
 echo "ok";
 }
 else
 {
 echo "CLICK upload";
 }
 ?>

</body>
</html>

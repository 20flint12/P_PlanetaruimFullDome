<?php
//session_start();

$slide1 = "slide1_0000007497.jpg";
$slide2 = "slide2_0000007497.jpg";
$slide3 = "slide3_0000007497.jpg";
$slide4 = "slide4_0000007497.jpg";
$slide5 = "slide5_0000007497.jpg";
$slide6 = "slide6_0000007497.jpg";
$slide7 = "slide7_0000007497.jpg";
$slide8 = "slide8_0000007497.jpg";

$dir = "Foto/";

if($_GET['id'] == 101){
	echo $dir . $slide1;
}

if($_GET['id'] == 102){
	echo $dir . $slide2;
}
	
if($_GET['id'] == 103){
	echo $dir . $slide3;
}
	
if($_GET['id'] == 104){
	echo $dir . $slide4;
}

if($_GET['id'] == 105){
	echo $dir . $slide5;
}

if($_GET['id'] == 106){
	echo $dir . $slide6;
}

if($_GET['id'] == 107){
	echo $dir . $slide7;
}


if($_GET['id'] == 108){
	echo $dir . $slide8;
}


if($_GET['id'] == 109){
	if($_SESSION['a'] == '0'){
	$_SESSION['a'] = '1';
	echo $dir . $slide8;
	}
	else{
	$_SESSION['a'] = '0'; 
	echo $dir . $slide8;
	}
}
?>
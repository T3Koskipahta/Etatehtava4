<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<link rel="stylesheet" type="text/css" href="css/main.css">
<script src="scripts/main.js"></script>
<title>Asiakas-ohjelma</title>
<style>
.oikealle{
	text-align: right;
}
</style>
</head>
<body onkeydown="tutkiKey(event)">
<table id="listaus">
	<thead>
		<tr>
			<th colspan="4" id="ilmo"></th>
			<th><a id="uusiAsiakas" href="lisaaasiakas.jsp">Lis?? uusi asiakas</a></th>
		</tr>	
		<tr>
			<th class="oikealle">Hakusana:</th>
			<th colspan="3"><input type="text" id="hakusana"></th>
			<th><input type="button" value="hae" id="hakunappi" onclick="haeTiedot()"></th>
		</tr>			
		<tr>
			<th>Etunimi</th>
			<th>Sukunimi</th>
			<th>Puhelin</th>
			<th>Sposti</th>		
			<th></th>						
		</tr>
	</thead>
	<tbody id="tbody">
	</tbody>
</table>
<script>
haeTiedot();	
document.getElementById("hakusana").focus();//vied??n kursori hakusana-kentt??n sivun latauksen yhteydess?

function tutkiKey(event){
	if(event.keyCode==13){//Enter
		haeTiedot();
	}		
}
//Funktio tietojen hakemista varten
//GET   /asiakkaat/{hakusana}
function haeTiedot(){	
	document.getElementById("tbody").innerHTML = "";
	fetch("asiakkaat/" + document.getElementById("hakusana").value,{//L?hetet??n kutsu backendiin
	      method: 'GET'
	    })
	.then(function (response) {//Odotetaan vastausta ja muutetaan JSON-vastaus objektiksi
		return response.json()	
	})
	.then(function (responseJson) {//Otetaan vastaan objekti responseJson-parametriss?		
		var asiakkaat = responseJson.asiakkaat;	
		var htmlStr="";
		for(var i=0;i<asiakkaat.length;i++){			
      	htmlStr+="<tr>";
      	htmlStr+="<td>"+asiakkaat[i].etunimi+"</td>";
      	htmlStr+="<td>"+asiakkaat[i].sukunimi+"</td>";
      	htmlStr+="<td>"+asiakkaat[i].puhelin+"</td>";
      	htmlStr+="<td>"+asiakkaat[i].sposti+"</td>";  
      	htmlStr+="<td><a href='muutaasiakas.jsp?asiakas_id="+asiakkaat[i].asiakas_id+"'>Muuta</a>&nbsp;";
      	htmlStr+="<span class='poista' onclick=poista('"+asiakkaat[i].asiakas_id+"','"+asiakkaat[i].etunimi+"','"+asiakkaat[i].sukunimi+"')>Poista</span></td>";
      	htmlStr+="</tr>";        	
		}
		document.getElementById("tbody").innerHTML = htmlStr;		
	})	
}
//Funktio tietojen poistamista varten. Kutsutaan backin DELETE-metodia ja v?litet??n poistettavan tiedon id. 
//DELETE /asiakkaat/id
function poista(asiakas_id, etunimi, sukunimi){
	if(confirm("Poista asiakas " + etunimi + " " + sukunimi +"?")){	
		fetch("asiakkaat/"+ asiakas_id,{//L?hetet??n kutsu backendiin
		      method: 'DELETE'		      	      
		    })
		.then(function (response) {//Odotetaan vastausta ja muutetaan JSON-vastaus objektiksi
			return response.json()
		})
		.then(function (responseJson) {//Otetaan vastaan objekti responseJson-parametriss?		
			var vastaus = responseJson.response;		
			if(vastaus==0){
				document.getElementById("ilmo").innerHTML= "Asiakkaan poisto ep?onnistui.";
	        }else if(vastaus==1){	        	
	        	document.getElementById("ilmo").innerHTML="Asiakkaan " + etunimi + " " + sukunimi + " poisto onnistui.";
				haeTiedot();        	
			}	
			setTimeout(function(){ document.getElementById("ilmo").innerHTML=""; }, 5000);
		})		
	}	
}


/* vanhat koodit t?st? eteenp?in -->
$(document).ready(function(){
	$("#uusiAsiakas").click(function(){
		document.location="lisaaasiakas.jsp";
	});
	haeasiakkaat();
	$("#hakunappi").click(function(){		
		haeasiakkaat();
	});
	$(document.body).on("keydown", function(event){
		  if(event.which==13){ //Enteri? painettu, ajetaan haku
			  haeasiakkaat();
		  }
	});
	$("#hakusana").focus();//vied??n kursori hakusana-kentt??n sivun latauksen yhteydess?
});	
function haeasiakkaat(){
	$("#listaus tbody").empty();
	$.ajax({url:"asiakkaat/"+$("#hakusana").val(),
			type:"GET", 
			dataType:"json", 
			success:function(result){//Funktio palauttaa tiedot json-objektina		
		$.each(result.asiakkaat, function(i, field){  
        	var htmlStr;
        	htmlStr+="<tr>";
        	htmlStr+="<tr id='rivi_"+field.asiakas_id+"'>";
        	htmlStr+="<td>"+field.etunimi+"</td>";
        	htmlStr+="<td>"+field.sukunimi+"</td>";
        	htmlStr+="<td>"+field.puhelin+"</td>";
        	htmlStr+="<td>"+field.sposti+"</td>";  
        	htmlStr+="<td><a href='muutaasiakas.jsp?asiakas_id="+field.asiakas_id+"'>Muuta</a)>&nbsp;";  
        	htmlStr+="<span class='poista' onclick=poista('"+field.asiakas_id+"','"+field.etunimi+"','"+field.sukunimi+"')>Poista</span></td>";
        	htmlStr+="</tr>";
        	$("#listaus tbody").append(htmlStr);
        });	
    }});
}
function poista(asiakas_id, etunimi, sukunimi){
	if(confirm("Poista asiakas " + etunimi + " " + sukunimi +"?")){
		$.ajax({url:"asiakkaat/"+asiakas_id, type:"DELETE", dataType:"json", success:function(result) { //result on joko {"response:1"} tai {"response:0"}
	        if(result.response==0){
	        	$("#ilmo").html("Asiakkaan poisto ep?onnistui.");
	        }else if(result.response==1){
	        	$("#rivi_"+asiakas_id).css("background-color", "red"); //V?rj?t??n poistetun asiakkaan rivi
	        	alert("Asiakkaan " + etunimi + " " + sukunimi + " poisto onnistui.");
	        	haeasiakkaat();        	
			}
	    }});
	}
}
<-- t?h?n loppui vanhat koodit  
*/

</script>
</body>
</html>
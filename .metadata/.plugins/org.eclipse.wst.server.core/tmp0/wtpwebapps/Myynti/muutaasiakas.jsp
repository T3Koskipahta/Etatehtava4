<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<script src="scripts/main.js"></script>
<link rel="stylesheet" type="text/css" href="css/main.css">
<title>Asiakkaan muutos</title>
</head>
<body onkeydown="tutkiKey(event)">
<form id="tiedot">
<table>
		<thead>	
			<tr>
				<th colspan="3" id="ilmo"></th>
				<th colspan="2" class="oikealle"><a href="listaaasiakkaat.jsp" id="takaisin">Takaisin listaukseen</a></th>
			</tr>		
			<tr>

				<th>Etunimi</th>
				<th>Sukunimi</th>
				<th>Puhelin</th>
				<th>Sposti</th>		
				<th></th>
			</tr>
		</thead>
		<tbody>
			<tr>
				
				<td><input type="text" name="etunimi" id="etunimi"></td>
				<td><input type="text" name="sukunimi" id="sukunimi"></td>
				<td><input type="text" name="puhelin" id="puhelin"></td>
				<td><input type="text" name="sposti" id="sposti"></td> 
				<td><input type="button" id="tallenna" value="Hyv?ksy" onclick="vieTiedot()"></td>
			</tr>
		</tbody>
	</table>
	<input type="hidden" name="asiakas_id" id="asiakas_id">
	<input type="hidden" name="vanhaid" id="vanhaid">
</form>
<span id="ilmo"></span>
</body>
<script>
function tutkiKeyX(event){
	if(event.keyCode==13){//Enter
		vieTiedot();
	}		
}

var tutkiKey = (event) => {
	if(event.keyCode==13){//Enter
		vieTiedot();
	}	
}
document.getElementById("etunimi").focus();//vied??n kursori etunimi-kentt??n sivun latauksen yhteydess?


//Haetaan muutettavan asiakkaan tiedot. Kutsutaan backin GET-metodia ja v?litet??n kutsun mukana muutettavan tiedon id
//GET /asiakkaat/haeyksi/id
var asiakas_id = requestURLParam("asiakas_id"); //Funktio l?ytyy scripts/main.js 
fetch("asiakkaat/haeyksi/" + asiakas_id,{//L?hetet??n kutsu backendiin
    method: 'GET'	      
  })
.then( function (response) {//Odotetaan vastausta ja muutetaan JSON-vastausteksti objektiksi
	return response.json()
})
.then( function (responseJson) {//Otetaan vastaan objekti responseJson-parametriss?	
	console.log(responseJson);
	document.getElementById("asiakas_id").value = asiakas_id;		
	document.getElementById("etunimi").value = responseJson.etunimi;	
	document.getElementById("sukunimi").value = responseJson.sukunimi;	
	document.getElementById("puhelin").value = responseJson.puhelin;
	document.getElementById("sposti").value = responseJson.sposti;
	document.getElementById("vanhaid").value = asiakas_id;	
});	

//Funktio tietojen muuttamista varten. Kutsutaan backin PUT-metodia ja v?litet??n kutsun mukana muutetut tiedot json-stringin?.
//PUT /autot/
function vieTiedot(){	
	var ilmo="";
	if(document.getElementById("etunimi").value.length<2){
		ilmo="Etunimi ei kelpaa!";		
	}else if(document.getElementById("sukunimi").value.length<2){
		ilmo="Sukunimi ei kelpaa!";		
	}else if(document.getElementById("puhelin").value.length<7){
		ilmo="Puhelin ei kelpaa!";		
	}else if(document.getElementById("sposti").value.length<7){
		ilmo="Sposti ei kelpaa!";		
	}
	if(ilmo!=""){
		document.getElementById("ilmo").innerHTML=ilmo;
		setTimeout(function(){ document.getElementById("ilmo").innerHTML=""; }, 3000);
		return;
	}
	document.getElementById("etunimi").value=siivoa(document.getElementById("etunimi").value);
	document.getElementById("sukunimi").value=siivoa(document.getElementById("sukunimi").value);
	document.getElementById("puhelin").value=siivoa(document.getElementById("puhelin").value);
	document.getElementById("sposti").value=siivoa(document.getElementById("sposti").value);	
		
	var formJsonStr=formDataToJSON(document.getElementById("tiedot")); //muutetaan lomakkeen tiedot json-stringiksi
	console.log(formJsonStr);
	//L?het??n muutetut tiedot backendiin
	fetch("asiakkaat",{//L?hetet??n kutsu backendiin
	      method: 'PUT',
	      body:formJsonStr
	    })
	.then( function (response) {//Odotetaan vastausta ja muutetaan JSON-vastaus objektiksi
		return response.json();
	})
	.then( function (responseJson) {//Otetaan vastaan objekti responseJson-parametriss?	
		var vastaus = responseJson.response;		
		if(vastaus==0){
			document.getElementById("ilmo").innerHTML= "Tietojen p?ivitys ep?onnistui";
      }else if(vastaus==1){	        	
      	document.getElementById("ilmo").innerHTML= "Tietojen p?ivitys onnistui";			      	
		}	
		setTimeout(function(){ document.getElementById("ilmo").innerHTML=""; }, 5000);
	});	
	document.getElementById("tiedot").reset(); //tyhjennet??n tiedot -lomake
}

/* vanha koodi alkaa -->
$(document).ready(function(){
	$("#takaisin").click(function(){
		document.location="listaaasiakkaat.jsp";
	});

	//Haetaan muutettavan auton tiedot. Kutsutaan backin GET-metodia ja v?litet??n kutsun mukana muutettavan tiedon id
	//GET /asiakkaat/haeyksi/asiakas_id
	var asiakas_id = requestURLParam("asiakas_id"); //Funktio l?ytyy scripts/main.js 	
	$.ajax({url:"asiakkaat/haeyksi/"+asiakas_id, type:"GET", dataType:"json", success:function(result){	
		$("#vanhaid").val(asiakas_id);	
		$("#asiakas_id").val(asiakas_id);		
		$("#etunimi").val(result.etunimi);	
		$("#sukunimi").val(result.sukunimi);
		$("#puhelin").val(result.puhelin);
		$("#sposti").val(result.sposti);	
		console.log(result.etunimi+" "+result.sukunimi+" "+result.puhelin+" "+result.sposti+" "+asiakas_id+" "+result.asiakas_id);
    }});
	

	
	$("#tiedot").validate({						
		rules: {
			etunimi:  {
				required: true,
				minlength: 2,
				maxlength: 50
			},	
			sukunimi:  {
				required: true,
				minlength: 2,	
				maxlength: 50
			},
			puhelin:  {
				required: true,
				minlength: 7,
				maxlength: 20
			},	
			sposti:  {
				required: true,
				minlength: 7,
				maxlength: 100,
			}	
		},
		messages: {
			etunimi: {     
				required: "Puuttuu",
				minlength: "Liian lyhyt",
				maxlength: "Liian pitk?"
			},
			sukunimi: {
				required: "Puuttuu",
				minlength: "Liian lyhyt",
				maxlength: "Liian pitk?"
			},
			puhelin: {
				required: "Puuttuu",
				minlength: "Liian lyhyt",
				maxlength: "Liian pitk?"
			},
			sposti: {
				required: "Puuttuu",
				minlength: "Liian lyhyt",
				maxlength: "Liian pitk?"
			}
		},			
		submitHandler: function(form) {	
			paivitaTiedot();
		}		
	});
});	
//funktio tietojen lis??mist? varten. Kutsutaan backin PUT-metodia ja v?litet??n kutsun mukana uudet tiedot json-stringin?.
//PUT /asiakkaat/
function paivitaTiedot(){	
	var formJsonStr = formDataJsonStr($("#tiedot").serializeArray()); //muutetaan lomakkeen tiedot json-stringiksi
	$.ajax({url:"asiakkaat", data:formJsonStr, type:"PUT", dataType:"json", success:function(result) { //result on joko {"response:1"} tai {"response:0"}       
		console.log(JSON.stringify(formJsonStr));
		if(result.response==0){
      	$("#ilmo").html("Asiakkaan p?ivitt?minen ep?onnistui.");
      } else if(result.response==1){			
      	$("#ilmo").html("Asiakkaan p?ivitt?minen onnistui.");
      	$("#asiakas_id","#etunimi", "#sukunimi", "#puhelin", "#sposti", "#vanhaid").val("");
		}
  }});	
}	
<-- vanha koodi loppuu
*/

</script>
</html>
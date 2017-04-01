<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    												pageEncoding="UTF-8" %>
<!doctype html>

<html lang="en">
<head>
<meta charset="utf-8">
<title>Strongly Connected Components</title>

<link rel="stylesheet"
              href="<c:url value="/resources/stylesheet/bfsDemo.css" />" />

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>


<script>

"use strict";

/*
This script creates a directed graph with a random edge distribution and finds all its strongly connected components. It executes two successive Depth first Trees, the first one on the graph itself, the second one on its transposed graph.  
*/


var Debugger = function() { };// create  object
  Debugger.log = function(message) {
  try {
    console.log(message);
  } catch(exception) {
    return;
  }
}


function canvasSupport() {
  	return !!document.createElement('canvas').getContext;
} 

function canvasApp() {

  	function Vertex(name) {
    	this.mName = name;
    	this.mPredecessor = null;
    	this.mColor = "black";
    	this.md = 0;
  	}// Vertex

  	// Vertex augmentation
  	function DisplayVertex(name) {
    	Vertex.call(this, name);
  	}// DisplayVertex

  	DisplayVertex.prototype = new Vertex();
  	DisplayVertex.prototype.mRadius = 20;
  	DisplayVertex.prototype.xPos = 0;
  	DisplayVertex.prototype.yPos = 0;
  	DisplayVertex.prototype.yConnU = 0;
  	DisplayVertex.prototype.yConnB = 0;
  	DisplayVertex.prototype.xConnL = 0;
  	DisplayVertex.prototype.xConnR = 0;
  	// 4 connection points, bottom, up, left, right
  	DisplayVertex.prototype.mNx = 0;
  	DisplayVertex.prototype.mNy = 0;
 
  	DisplayVertex.prototype.updateGeometry = function() {  
    	this.yConnU = this.yPos - this.mRadius;
    	this.yConnB = this.yPos + this.mRadius;
    	this.xConnL = this.xPos - this.mRadius;
    	this.xConnR = this.xPos + this.mRadius;
  	};

  	/*
    var geometry = 
		{"a0": [0, 0], "b0": [1, 0], "c0": [2, 0], "d0": [3, 0], "e0": [4, 0], "f0": [5, 0], "g0": [6, 0],
		 "a1": [0, 1], "b1": [1, 1], "c1": [2, 1], "d1": [3, 1], "e1": [4, 1], "f1": [5, 1], "g1": [6, 1],
	 	 "a2": [0, 2], "b2": [1, 2], "c2": [2, 2], "d2": [3, 2], "e2": [4, 2], "f2": [5, 2], "g2": [6, 2],  
	 	 "a3": [0, 3], "b3": [1, 3], "c3": [2, 3], "d3": [3, 3], "e3": [4, 3], "f3": [5, 3], "g3": [6, 3],
	 	 "a4": [0, 4], "b4": [1, 4], "c4": [2, 4], "d4": [3, 4], "e4": [4, 4], "f4": [5, 4], "g4": [6, 4]
	};
  	*/
    
    var geometry = 
		{"a0": [0, 0], "b0": [1, 0], "c0": [2, 0], "d0": [3, 0], "e0": [4, 0], "f0": [5, 0],
	 "a1": [0, 1], "b1": [1, 1], "c1": [2, 1], "d1": [3, 1], "e1": [4, 1], "f1": [5, 1], 
 	 "a2": [0, 2], "b2": [1, 2], "c2": [2, 2], "d2": [3, 2], "e2": [4, 2], "f2": [5, 2], 
 	 "a3": [0, 3], "b3": [1, 3], "c3": [2, 3], "d3": [3, 3], "e3": [4, 3], "f3": [5, 3], 
 	 "a4": [0, 4], "b4": [1, 4], "c4": [2, 4], "d4": [3, 4], "e4": [4, 4], "f4": [5, 4], 
	};
	
  	

    function WeightedEdge() {
  	  this.to;//adjacent vertex
  	  this.weight;// edge weight
    }
  	
  	// base class
  	function Graph(N) {// A Graph contains a vector of N vertices
    	this.mV = [];// al vertices
    	this.mAdj = [];// indexes of adjacent nodes
    	this.mE = [];// all edges
    	this.mAdjE = [];// handles to adjacent starting edges
    	this.init = function() {
      		for (var i = 0; i < N; i++) {
        		this.mAdj.push(new Array());
      		}
    	}; 
    	// array of arrays of arrays format [[v,v,v],[]...[]]
    	// v = vertex number 
    	this.init();
  	};// Graph


  	// get canvas context
  	if (!canvasSupport()) {
    	alert("canvas not supported");
    	return;
  	} else {
    	var theCanvas = document.getElementById("canvas");
    	var context = theCanvas.getContext("2d");
  	}// if

  	var xMin = 0;
  	var yMin = 0;
  	var xMax = theCanvas.width;
  	var yMax = theCanvas.height; 

  	//var xPos = [50, 150, 250, 350, 450, 550, 650];
  	//var yPos = [100, 200, 300, 400, 500];
  	var xPos = [50, 170, 290, 410, 530, 650];
  	var yPos = [100, 200, 300, 400, 500];

  	var names = ["a", "b", "c", "d", "e", "f" ,"g"];

  	var message;
  
  	var graphReady;
  
  	var searchOK;
  	var search2OK;
  
  	var time;
  	var N = 30;
  	var Nedges = 60;
  	
  	var result;

  	var graph = new Graph(N);// empty graph
  	var connGraph;// SCC 

  	var ind;

  	function setTextStyle() {
    	context.fillStyle    = '#000000';
    	context.font         = '12px _sans';
  	}

  	function fillBackground() {
    	// draw background
    	context.fillStyle = '#ffffff';
    	context.fillRect(xMin, yMin, xMax, yMax);    
  	}// fillBackground


  	function drawVertex(vertex) {
		
      	context.strokeStyle = vertex.mColor; 
    	
    	context.beginPath(); 
    	context.lineWidth = 2;
    	context.arc(vertex.xPos, vertex.yPos, vertex.mRadius, (Math.PI/180)*0, (Math.PI/180)*360, true); // draw full circle
    	context.stroke();
    	context.closePath();   
    
    	var roff = vertex.mRadius + 2;
		var display = "";
	
		if (vertex.md != null) {
      		display += " " + vertex.md; 
    	}

    	context.fillText(vertex.mName, vertex.xPos, vertex.yPos);    
    	context.fillText(display, vertex.xPos + roff, vertex.yPos - roff);

  	}// drawVertex

  	
  	function drawConnectMST(v1, v2, w, arc, color) {
  		
  		if (color != null) {
  	    	context.strokeStyle = color;
  		} else {
  		  	context.strokeStyle = "black";
  		}
  	    // discuss according to geometry, always from v1 to v2 (directed graph)
  	    var xa, ya, xb, yb;
  	    var xoff = 0;
  	    var yoff = 0;
  	    if (v1.mNx == v2.mNx) {
  	      xa = v1.xPos;
  	      xb = v1.xPos;
  	      if (v1.mNy < v2.mNy) {    
  	        ya = v1.yConnB;       
  	        yb = v2.yConnU;
  	      } else {
  	        ya = v1.yConnU;       
  	        yb = v2.yConnB;
  	      }
  	    } else if (v1.mNy == v2.mNy) {
  	      ya = v1.yPos;
  	      yb = v1.yPos; 
  	      if (v1.mNx < v2.mNx) {
  	        xa = v1.xConnR; 
  	        xb = v2.xConnL; 
  	      } else {
  	        xa = v1.xConnL;         
  	        xb = v2.xConnR; 
  	      }         
  	    } else {
  	      if (v1.mNx < v2.mNx) {
  	        xa = v1.xConnR;
  	        xb = v2.xConnL;
  	        ya = v1.yPos;
  	        yb = v2.yPos;
  	        if (v1.mNy < v2.mNy) { 
  	          xoff = -10; yoff = -10; 
  	        } else { 
  	          xoff = 10; yoff = -10; 
  	        }           
  	      } else {
  	        xa = v1.xConnL;
  	        xb = v2.xConnR;
  	        ya = v1.yPos;
  	        yb = v2.yPos;
  	        if (v1.mNy < v2.mNy) { 
  	          xoff = 10; yoff = -10; 
  	        } else { 
  	          xoff = -10; yoff = -10; 
  	        }         
  	      }      
  	    }
  	    if (arc == 1) {
  	      drawArcWeight([xa, ya], [xb, yb], xoff, yoff, w);
  	    } else {
  	      drawLineWeight([xa, ya], [xb, yb], xoff, yoff, w);
  	    }
  	}// drawConnectMST

    
    function drawLineWeight(a, b, xoff, yoff, weight) {// a and b points   
        var xa = a[0];
        var ya = a[1];
        var xb = b[0];
        var yb = b[1];
       
        context.beginPath();
        context.moveTo(xa, ya);
        context.lineTo(xb, yb);
        context.stroke();
        context.closePath();
        
        if (weight != null) {
        	// get midpoint
        	var xm = (xa + xb) / 2 + xoff;
        	var ym = (ya + yb) / 2 + yoff;

        	context.textBaseline = "bottom";
        	context.textAlign = "right";
        	context.fillText(weight, xm, ym);   
        	context.textBaseline = "middle";
        	context.textAlign = "center"; 
        }
        
        // get unity vector from a to b
        var dx = xa - xb;
        var dy = ya - yb;
        var l = Math.sqrt(dx * dx + dy * dy);
        var u = [dx/l, dy/l];
        var angle = (Math.PI / 180) * 15;
        var a1x = Math.cos(angle) * u[0] - Math.sin(angle) * u[1];
        var a1y = Math.sin(angle) * u[0] + Math.cos(angle) * u[1];
        var a2x = Math.cos(angle) * u[0] + Math.sin(angle) * u[1];
        var a2y = -Math.sin(angle) * u[0] + Math.cos(angle) * u[1];
        var a1 = [xb + a1x*10, yb + a1y*10];
        var a2 = [xb + a2x*10, yb + a2y*10];

        context.beginPath();
        context.moveTo(xb, yb);
        context.lineTo(a1[0], a1[1]);
        context.stroke();
        context.moveTo(xb, yb);
        context.lineTo(a2[0], a2[1]);
        context.stroke();
        context.closePath();   
    
    }// drawLineWeight
    
  	
  	function drawArcWeight(a, b, xoff, yoff, weight) {// a and b points 
  	    // drawArc from a to b
  	    var xa = a[0];
  	    var ya = a[1];
  	    var xb = b[0];
  	    var yb = b[1];

  	    // get center coordinates
  	    var phi = (Math.PI/180)*30;
  	   
  	    var xm = (xa + xb) / 2; 
  	    var ym = (ya + yb) / 2;
  	    var xc = xm + (yb - ya)/(2*Math.tan(phi));
  	    var yc = ym + (xa - xb)/(2*Math.tan(phi));

  	    // get radius
  	    var radius = Math.sqrt( (xa - xb)*(xa - xb)+(ya - yb)*(ya - yb) ) / (2*Math.sin(phi));
  	    var phia = Math.atan((yc - ya) / (xa - xc));
  	    if (xa < xc) {
  	      phia += Math.PI;
  	    }
  	    var phib = phia + 2*phi; 
  	    context.beginPath();
  	    context.arc(xc, yc, radius, -phia, -phib, true);  
  	    context.stroke();
  	    context.closePath();
  	    context.textBaseline = "middle";
  	    context.textAlign = "center"; 

  	    // get tangent vector at B
  	    var xt = Math.sin(phib);
  	    var yt = Math.cos(phib);
  	    var u = [xt, yt];
  	    var angle = (Math.PI / 180) * 15;

  	    var a1x = Math.cos(angle) * u[0] - Math.sin(angle) * u[1];
  	    var a1y = Math.sin(angle) * u[0] + Math.cos(angle) * u[1];
  	    var a2x = Math.cos(angle) * u[0] + Math.sin(angle) * u[1];
  	    var a2y = -Math.sin(angle) * u[0] + Math.cos(angle) * u[1];
  	    var a1 = [xb + a1x*10, yb + a1y*10];
  	    var a2 = [xb + a2x*10, yb + a2y*10];

  	    context.beginPath();
  	    context.moveTo(xb, yb);
  	    context.lineTo(a1[0], a1[1]);
  	    context.stroke();
  	    context.moveTo(xb, yb);
  	    context.lineTo(a2[0], a2[1]);
  	    context.stroke();
  	    context.closePath();   

  	    if (weight != null) {
  	    	// get midpoint
  	    	var xmd = xc + radius * Math.cos((phia + phib)/2) + xoff;
  	    	var ymd = yc + radius * -Math.sin((phia + phib)/2) + yoff;
  	    	context.textBaseline = "bottom";
  	    	context.textAlign = "right";
  	    	context.fillText(weight, xmd, ymd);
  	    }// if
  	  
    }// drawArcWeight

  	 	
  	function buildDirected(graph, Nedges) {
  		// building a graph
    	setTextStyle();

    	context.textBaseline = "middle";
    	context.textAlign = "center";

    	var vertex;

    	for (var i = 0; i < 5; i++) {
      		for (var j = 0; j < 6; j++) {
        		vertex = new DisplayVertex(names[j] + i);
        		vertex.mNx = j;
        		vertex.mNy = i;
        		vertex.xPos = xPos[j];
        		vertex.yPos = yPos[i];
        		vertex.updateGeometry();        
        		graph.mV.push(vertex);
        		drawVertex(vertex);         
      		}// for
    	}// for
    
    	randomize();
    	$('#initelem').find(':submit')[0].disabled = false;
    	    
	}// buildDirected

  	function initDraw(graph) {// graph is weighted directed
    	// only use mAdj for drawing connections
    	// clear canvas
   
    	var N = graph.mV.length;
  	
    	fillBackground();

    	setTextStyle();

    	context.textBaseline = "middle";
    	context.textAlign = "center";

    	// draw all vertices
    	for (var i = 0; i < N; i++) {
      		drawVertex(graph.mV[i]);
    	}
    	
    	var arc = 0;
    	// draw all connections
    	for (var i = 0; i < N; i++) {// for each vertex
      		var conn = graph.mAdj[i]; // all vertices connected to vertex i
      		for (var k = 0; k < conn.length; k++) {
        		arc = (graph.mAdj[conn[k]].indexOf(i) >= 0) ? 1 : 0;
        		drawConnectMST(graph.mV[i], graph.mV[conn[k]], null, arc, null); 
      		}
    	}
	}// initDraw
	
	
	
  	function redraw(graph) {// graph is weighted directed
    	// only use mAdj for drawing connections
    	// clear canvas
   
    	var N = graph.mV.length;
  	
    	fillBackground();

    	setTextStyle();

    	context.textBaseline = "middle";
    	context.textAlign = "center";

    	// draw all vertices
    	for (var i = 0; i < N; i++) {
      		drawVertex(graph.mV[i]);
    	}
    	
    	var arc = 0;
    	var weight = 0;
    	// draw all connections
    	for (var i = 0; i < N; i++) {// for each vertex
      		var conn = graph.mAdj[i]; // all vertices connected by an edge from vertex i
      
      		for (var k = 0; k < conn.length; k++) {
      			
      			var list = [];
      			for (var k2 = 0; k2 < graph.mAdj[conn[k].to].length; k2++) {
      				list.push(graph.mAdj[conn[k].to][k2].to);
      			}
      			var color;
   
      			if (graph.mV[conn[k].to].mPredecessor == i) {
      			
      				color = "blue";
      			} else {
      				color = "black";
      			} 
      		
      			weight = conn[k].weight;
        		arc = (list.indexOf(i) >= 0) ? 1 : 0;
    	
        		drawConnectMST(graph.mV[i], graph.mV[conn[k].to], weight, arc, color);  
      		}
    	}
	}// redraw

  
	function initGraph() {
	  	console.log("initGraph");
	  
	  	var message;
	    
  		var edgeArray = [];
  		var vertexArray = [];
  
  		var count = 0;
  		var edges;
  		var vertices;
		
  		for (var i1 = 0; i1 < N; i1++) {// for each vertex
			vertexArray.push({"name":graph.mV[i1].mName});
			for (var i2 = 0; i2 < graph.mAdj[i1].length; i2++) {// for each adjacent vertex
				console.log("push edge: " + i1 + " " + graph.mAdj[i1][i2]);
				edgeArray.push({"from":i1, "to":graph.mAdj[i1][i2]});
			}// i2
  		}// i1
		   
  		edges = {"jsonEdges":edgeArray};
  		vertices = {"jsonVertices":vertexArray};
  		message = {"jsonEdges":edgeArray, "jsonVertices":vertexArray};
  	
  		
  		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : '<c:url value="/initGraph" />',
			data : JSON.stringify(message),
			dataType : 'json',
			timeout : 100000,
			success : function(data) {
				console.log("INITIALIZATION SUCCESSFUL");
				graphReady = true;
			 	$('#largestSccForm').find(':submit')[0].disabled = false;
			},
		
			error : function(e) {
				console.log("ERROR: ", e);
			},
			done : function(e) {
				console.log("DONE");
			}
		});
 
		console.log("initGraph completed");
		$('#status').text('Ready to search');
		
  	}// initGraph

  	function randomize() {
    	// directed graph, adjacence matrix asymmetric

    	var edges = 0;
   
    	var check = new Array(N);
    	for (var i = 0; i < N; i++) {
      		check[i] = new Array(N);
    	}

    	for (var i = 0; i < N; i++) {
      		for (var j = 0; j < N; j++) {
       			check[i][j] = 0;
      		}
    	}

    	var index1, index2;

    	// reset all vertices
    	for (var i = 0; i < graph.mV.length; i++) {
      		graph.mV[i].mColor = "black";
      		graph.mV[i].mParent = null;
      		graph.mV[i].mTree = null;
      		graph.mV[i].md = 0;
      		graph.mV[i].mf = 0;
    	}

    	// remove all existing edges
    	for (var i = 0; i < graph.mAdj.length; i++) {
      		graph.mAdj[i] = [];
    	}

    	while (edges < Nedges) {
      		index1 = Math.floor(Math.random() * N);// range
      		index2 = index1;
      		while (index2 == index1) {
        		index2 = Math.floor(Math.random() * N);// range
      		}
      		var nX1 = graph.mV[index1].mNx;
      		var nY1 = graph.mV[index1].mNy;
      		var nX2 = graph.mV[index2].mNx;
      		var nY2 = graph.mV[index2].mNy;      
      		if ((Math.abs(nX1-nX2) <= 1) && (Math.abs(nY1-nY2) <= 1) ) {// allow edge      
        		// check edge already present
        		if (check[index1][index2] == 0) {
          			graph.mAdj[index1].push(index2);// directed graph, no symmetry
          			check[index1][index2] = 1;// directed graph, no symmetry
          			edges++;
        		}        
      		}
    	}// while
    	
    	/*	
    	 graph.mAdj[0] = [8, 7, 1 ]; 
    	 //graph.mAdj[1] = [7, 0 ]; 
    	 graph.mAdj[2] = [9, 10 ]; 
    	 //graph.mAdj[3] = [9, 11 ]; 
    	 graph.mAdj[4] = [10, ]; 
    	 //graph.mAdj[5] = [13, 12 ]; 
    	 graph.mAdj[6] = [12, ]; 
    	 //graph.mAdj[7] = [1, 0 ]; 
    	 graph.mAdj[8] = [15, 16, 9 ]; 
    	 //graph.mAdj[9] = [8, 10, 2 ]; 
    	 graph.mAdj[10] = [3, 16, 17 ]; 
    	 //graph.mAdj[11] = [19, 5, 3, 17 ]; 
    	 graph.mAdj[12] = [11, 5 ]; 
    	 //graph.mAdj[13] = [6 ]; 
    	 graph.mAdj[14] = [8, 7 ]; 
    	 graph.mAdj[15] = [23, 14, 8, 16 ]; 
    	 graph.mAdj[16] = [22, 8 ]; 
    	 graph.mAdj[17] = [25, 11, 18 ]; 
    	
    	 graph.mAdj[18] = [25, 19, 26, 11, 24 ]; 
    	 graph.mAdj[19] = [12, 20, 11, 27, 18 ]; 
    	 graph.mAdj[20] = [19, 13 ]; 
    	 graph.mAdj[21] = [28 ]; 
    	 graph.mAdj[22] = [30 ]; 
    	 graph.mAdj[23] = [16, 15, 30 ]; 
    	 graph.mAdj[24] = [23, 25, 16 ]; 
    	 graph.mAdj[25] = [17, 31 ]; 
    	 graph.mAdj[26] = [20, 34, 25, 27 ]; 
    	 graph.mAdj[27] = []; 
    	 graph.mAdj[28] = [21 ]; 
    	 graph.mAdj[29] = [23 ]; 
    	 graph.mAdj[30] = [23, 29, 24, 22 ]; 
    	 graph.mAdj[31] = [32, 24, 25 ]; 
    	 graph.mAdj[32] = [26 ]; 
    	 graph.mAdj[33] = []; 
    	 graph.mAdj[34] = [33, 26 ]; 
    	*/
    		
    		
    	// reset all vertices
    	for (var i = 0; i < N; i++) {
    		graph.mV[i].md = null;
    		//graph.mV[i].mF = null;
    		//graph.mV[i].mTree = null;
    	}
    		
    	initDraw(graph);

    	$('#initForm').find(':submit')[0].disabled = false;
		$('#status').text('Ready to init graph');
 	}// randomize
 
	function lSccSearch() {
		
		message = {"type":"SCCSEARCH"};// minimal message
		
		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : '<c:url value="/findLargestSCC" />',
			data : JSON.stringify(message),
			dataType : 'json',
			timeout : 100000,
			success : function(data) {
				console.log("LARGEST SCC SEARCH SUCCESSFUL");
				
				if (data["status"] == "OK") {
					
  					connGraph = jsonParse(data["snapshot"]);
  					
	  				redraw(connGraph);		
				}
		
				$('#status').text('Largest SCC built');
			   	$('#stepForm').find(':submit')[0].disabled = false;
			   	$('#initForm').find(':submit')[0].disabled = true;
			  	$('#largestSccForm').find(':submit')[0].disabled = true;
			},
		
			error : function(e) {
				console.log("ERROR: ", e);
			},
			done : function(e) {
				console.log("DONE");
			}
		});
 	}
 	
 	function searchStep() {
 		console.log("fuuucking searchstep");
 		
		message = {"type":"STEP"};// minimal message
	   	$('#largestSccForm').find(':submit')[0].disabled = true;
		
		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : '<c:url value="/searchStep" />',
			data : JSON.stringify(message),
			dataType : 'json',
			timeout : 100000,
			success : function(data) {
				console.log("SEARCH STEP SUCCESSFUL");
				if (data["status"] == "STEP" || data["status"] == "FINISHED") {
									
					connGraph = jsonParse(data["snapshot"]);
				
					redraw(connGraph);
					
					if (data["status"] == "STEP") {
						$('#status').text('Building Shortest Paths Tree...');
					} else {
					   	$('#stepForm').find(':submit')[0].disabled = true;
						$('#status').text('Shortest Paths Tree completed');
					}// if
					
				}// if
				
			},
		
			error : function(e) {
				console.log("ERROR: ", e);
			},
			done : function(e) {
				console.log("DONE");
			}
		});

 		
 		console.log("searchStep completed");
 	}
 
 	function jsonParse(result) {
 		
 		var snapVertices = result["vertices"];
		var snapAdjacencies = result["adjacencies"];
				
		var connGraph = new Graph(snapVertices.length);
		
		var forge;
		
		for (var i1 = 0; i1 < snapVertices.length; i1++) {
			
			connGraph.mV[i1] = new DisplayVertex(snapVertices[i1].name);
			connGraph.mV[i1].mNx = geometry[snapVertices[i1].name][0];
			connGraph.mV[i1].mNy = geometry[snapVertices[i1].name][1];
			connGraph.mV[i1].xPos = xPos[connGraph.mV[i1].mNx];
			connGraph.mV[i1].yPos = yPos[connGraph.mV[i1].mNy];
			connGraph.mV[i1].updateGeometry();
			connGraph.mV[i1].mColor = snapVertices[i1].color;
			connGraph.mV[i1].md = snapVertices[i1].d;
			connGraph.mV[i1].mPredecessor 
									= snapVertices[i1].predecessor;
			
			connGraph.mAdj[i1] = [];
							
			forge = snapAdjacencies[i1].adjacency;// weighted edge
		
			for (var k = 0; k < forge.length; k++) {
			
				var edge = new WeightedEdge();
				
				edge.to = forge[k]["to"];
				edge.weight = forge[k]["weight"];

				connGraph.mAdj[i1].push(edge);
									
			}// for
			
		}// for
 		
 		return connGraph;
 	}
  
  	buildDirected(graph, Nedges);
  
  	$("#largestSccForm").submit(function(event) { lSccSearch(); return false; });

  	$("#initForm").submit(function(event) { initGraph(); return false; });
  	
 	$("#stepForm").submit(function(event) { searchStep(); return false; });
	
  	$("#initelem").submit(function(event) { randomize(); return false; });
  	
   	$('#largestSccForm').find(':submit')[0].disabled = true;
   	$('#stepForm').find(':submit')[0].disabled = true;
  
}// canvasApp


function eventWindowLoaded() {
  canvasApp();
}// eventWindowLoaded()

window.addEventListener('load', eventWindowLoaded, false);

</script>
</head>


<body>

  <header id="intro">
  <h1>Strongly Connected Graph Components using Depth First Search</h1>
  <p>I present here a Java based demonstration of the Dijkstra algorithm applied to a directed graph.<br/>
  This graph is strongly connected to make the demonstration easier.<br/>
  The strong connectedness is not a prerequisite for the Dijkstra algorithm.</p>

  <h2>Explanations</h2>
  <p>The graph edges are randomly initialized.<br>
The largest strongly connected component is extracted using two successive applications of the Depth First Search algorithm.<br/>
This component is equipped with random positive weights.<br/>
Then the Dijkstra algorithm is applied step-by-step to the component, always using as source the vertex with index 0.<br/>
A newly visited vertex is colored green. A finalized vertex is colored blue.<br/>
The distance to the source is also displayed for each vertex. 
The edges that belong to the Shortest Path Tree are colored blue, the other edges are colored black.</p>
  </header>

  <div id="display">
    <canvas id="canvas" width="700" height="600">
      Your browser does not support HTML 5 Canvas
    </canvas>
    <footer>
      <p>Dominique Ubersfeld, Cachan</p>
    </footer> 
 
  </div>

  <div id="controls">
    <div id="SCC">
      <p>Click here to find all strongly connected components</p>
      <form name="largestSccForm" id="largestSccForm">
        <input type="submit" name="search-btn" value="Find largest SCC">
      </form>
      <p>Click here for a step</p>
      <form name="stepFormForm" id="stepForm">
        <input type="submit" name="search-btn" value="Step">
      </form>
      <p>Click here to initialize</p>
      <form name="initForm" id="initForm">
        <input type="submit" name="search-btn" value="Init">
      </form>
  
    </div>
    <div id="randomize">
      <p>Click here to randomize the graph edges</p>
      <form name="initialize" id="initelem">
        <input type="submit" name="randomize-btn" value="Randomize">
      </form>
    </div>    
    <div id="msg">
      <p id="status"></p>
    </div> 
    
  </div>

</body>

</html>

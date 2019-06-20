package com.dub.spring.controller;


import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.dub.spring.stronglyConnectedComponents.DFSGraph;
import com.dub.spring.stronglyConnectedComponents.GraphInitRequest;
import com.dub.spring.stronglyConnectedComponents.GraphServices;
import com.dub.spring.stronglyConnectedComponents.JSONEdge;
import com.dub.spring.stronglyConnectedComponents.JSONSnapshot;
import com.dub.spring.stronglyConnectedComponents.JSONVertex;
import com.dub.spring.stronglyConnectedComponents.SPTGraph;
import com.dub.spring.stronglyConnectedComponents.SPTResponse;
import com.dub.spring.stronglyConnectedComponents.SearchRequest;


@Controller
public class SCCController {
	
	@Autowired
	private GraphServices graphServices;
	
	/** Initialize graph for SCC search */
	@RequestMapping(value="/initGraph")
	@ResponseBody
	public SPTResponse initGraph(@RequestBody GraphInitRequest message, 
				HttpServletRequest request) 
	{	
		
		List<JSONEdge> jsonEdges = message.getJsonEdges();
		List<JSONVertex> jsonVertices = message.getJsonVertices();
		
		HttpSession session = request.getSession();
		
		if (session.getAttribute("graph") != null) {
			session.removeAttribute("graph");
		}
		
		DFSGraph graph = graphServices.jsonToDFS(jsonEdges, jsonVertices);
		
		session.setAttribute("graph", graph);
			
		SPTResponse sptResponse = new SPTResponse();
		sptResponse.setStatus(SPTResponse.Status.OK);
		
		// here the graph is ready for the search loop
	
		System.out.println("initGraph completed");
			
		return sptResponse;
	}
		
	@RequestMapping(value="/findLargestSCC")
	@ResponseBody
	public SPTResponse findLargestSCC(@RequestBody SearchRequest message, 
											HttpServletRequest request) 
	{	
		System.out.println("controller: findLargestSCC begin");
		
		SPTResponse sptResponse = new SPTResponse();
		
		/** retrieve the graph from the session context */
		HttpSession session = request.getSession();
		
		if (session.getAttribute("comp") != null) {
			session.removeAttribute("comp");
		}
		
		DFSGraph graph = (DFSGraph)session.getAttribute("graph");
						
		SPTGraph comp = graph.getLargestSCC();
			
		comp.randomizeWeights();
		
		/** equip the component with random weights */
		comp.displayWeights();
		
		/** initialize the component fro Dijkstra algorithm */
		comp.initDijkstra();
		
		JSONSnapshot snapshot = graphServices.sptToJSON(comp);
		
		sptResponse.setSnapshot(snapshot);
		sptResponse.setStatus(SPTResponse.Status.OK);
		
		/** attach component to session context */
		session.setAttribute("comp", comp);
		
		System.out.println("controller: findSCC return");
		return sptResponse;
	}// findSCC
	
	@RequestMapping(value="/searchStep")
	@ResponseBody
	public SPTResponse searchStep(@RequestBody SearchRequest message, 
											HttpServletRequest request) 
	{	
	
		/** retrieve component from session context */
		HttpSession session = request.getSession();
		SPTGraph comp = (SPTGraph)session.getAttribute("comp");
		
		//comp.displaySPT();
		
		comp.searchStep();
		
		SPTResponse sptResponse = new SPTResponse();
		
		JSONSnapshot snapshot = graphServices.sptToJSON(comp);
		
		sptResponse.setSnapshot(snapshot);
		
		if (!comp.isFinished()) {
			sptResponse.setStatus(SPTResponse.Status.STEP);
		} else {
			sptResponse.setStatus(SPTResponse.Status.FINISHED);
		}
		return sptResponse;
	}// searchStep
}

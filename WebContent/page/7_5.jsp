<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="com.Dbutil"%>
<%@page import="org.bson.Document"%>
<%@page import="com.mongodb.MongoClient"%>
<%@page import="com.mongodb.client.MongoCollection"%>
<%@page import="com.mongodb.client.MongoDatabase"%>
<%@page import="com.mongodb.client.FindIterable"%>
<%@page import="com.mongodb.client.MongoCursor"%>
<%@page import="static com.mongodb.client.model.Filters.*"%>
<%@page import="com.mongodb.client.AggregateIterable" %>
<%@page import="java.util.Arrays" %>
<%@page import="static com.mongodb.client.model.Projections.*" %>
<%@page import="org.bson.conversions.Bson" %>
<%@page import="static com.mongodb.client.model.Aggregates.*" %>
<%@page import="static com.mongodb.client.model.Accumulators.*" %>
<%@page import="com.mongodb.client.model.Sorts" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>查询每个课程的最高成绩以及最高成绩对应的学生名</title>
<link rel="stylesheet" href="../layui/css/layui.css"  media="all">
</head>
<body>
<table class="layui-table" lay-filter="parse-table-demo" lay-data="{id: 'idTest'}">
	<thead>
    <tr>
    	<th lay-data="{field:'1', width:150,fixed:'left'}">CID</th>
    	<th lay-data="{field:'2', width:150,fixed:'left'}">Course_NAME</th>
        <th lay-data="{field:'3', width:150}">SID</th>
        <th lay-data="{field:'4', width:150}">Student_NAME</th>
        <th lay-data="{field:'5', width:150}">SCORE</th>
    </tr> 
  </thead>
  <tbody>
<%
Document doc,doc1=null,doc2=null,doc3=null;
MongoDatabase db=new Dbutil().getdb();
MongoCollection<Document> mc = db.getCollection("student_course");
AggregateIterable<Document> iterable = mc.aggregate(Arrays.asList(
 		group("$CID", max("max_score","$SCORE"))
		));
MongoCursor<Document> cursor = iterable.iterator();
while(cursor.hasNext()) {
doc = cursor.next();
MongoCollection<Document> collection3 = db.getCollection("course");
MongoCursor<Document> mongoCursor3 = collection3.find(eq("CID",doc.get("_id"))).projection(fields(include("NAME"),excludeId())).iterator();  
if(mongoCursor3.hasNext()){  
   doc3=mongoCursor3.next();
}
MongoCollection<Document> collection1 = db.getCollection("student_course");
MongoCursor<Document> mongoCursor1 = collection1.find(and(eq("SCORE",doc.get("max_score")),eq("CID",doc.get("_id")))).projection(fields(include("SID"),excludeId())).iterator();  
while(mongoCursor1.hasNext()){  
   doc1=mongoCursor1.next();
%>
	<tr>
   		<td><%=doc.get("_id") %></td>  
   		<td><%=doc3.get("NAME") %></td>  
     	<td><%=doc1.get("SID") %></td>
<% 
MongoCollection<Document> collection2 = db.getCollection("student");
MongoCursor<Document> mongoCursor2 = collection2.find(eq("SID",doc1.get("SID"))).projection(fields(include("NAME"),excludeId())).iterator();  
if(mongoCursor2.hasNext()){  
   doc2=mongoCursor2.next();
}
%>
     	<td><%=doc2.get("NAME") %></td>
     	<td><%=doc.get("max_score") %></td>
<%
}
}
%>
</tbody>
</table>
<script src="../layui/layui.js" charset="utf-8"></script>
<script type="text/javascript">
layui.use('table', function(){
	  var table = layui.table;
	      table.init('parse-table-demo', { //转化静态表格
	        //height: 'full-500'
			page:true
	      });
	    });
</script>
</body>
</html>
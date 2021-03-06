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
<%@page import="java.util.List" %>
<%@page import="java.util.ArrayList" %>
<%@page import="static com.mongodb.client.model.Projections.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>找出平均成绩排名前10的学生</title>
<link rel="stylesheet" href="../layui/css/layui.css"  media="all">
</head>
<body>
<table class="layui-table" lay-filter="parse-table-demo" lay-data="{id: 'idTest'}">
	<thead>
    <tr>
    	<th lay-data="{field:'1', width:150,fixed:'left'}">SID</th>
        <th lay-data="{field:'2', width:150}">NAME</th>
        <th lay-data="{field:'7', width:150}">avg_score</th>
    </tr> 
  </thead>
  <tbody>
<%
Document doc,doc1=null;
MongoDatabase db=new Dbutil().getdb();
MongoCollection<Document> collection = db.getCollection("student_course");
Document sub_group = new Document();
sub_group.put("_id", "$SID");
sub_group.put("avg_score", new Document("$avg","$SCORE"));
Document group = new Document("$group", sub_group);
Document sort = new Document("$sort", new Document("avg_score", -1));
Document limit =new Document("$limit",10);
List<Document> aggregateList = new ArrayList<Document>();
aggregateList.add(group);
aggregateList.add(sort);
aggregateList.add(limit);
AggregateIterable<Document> resultset = collection.aggregate(aggregateList);
MongoCursor<Document> cursor = resultset.iterator();
while(cursor.hasNext()) {
	doc = cursor.next();
%>
	<tr>
   		<td><%=doc.get("_id") %></td>  
<%
MongoCollection<Document> collection1 = db.getCollection("student");
MongoCursor<Document> mongoCursor1 = collection1.find(eq("SID",doc.get("_id"))).projection(fields(include("NAME"),excludeId())).iterator();  
if(mongoCursor1.hasNext()){  
   doc1=mongoCursor1.next();
}
%>
     	<td><%=doc1.get("NAME") %></td>
     	<td><%=doc.get("avg_score") %></td>
   </tr>
<% 
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
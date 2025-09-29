<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="info.item" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"/>
  <title>Identification</title>
  <style>
    :root{
      --bg1:#9dd3c4;
      --bg2:#82b9d8;
      --card:#e5f3ef;
      --btn:#1e5b50;
      --btn-text:#eaf3f1;
      --nav:#7fb2d2;
      --ink:#0f1b1a;
      --radius:16px;
      --success:#28a745;
      --warning:#ffc107;
    }
    *{box-sizing:border-box}
    html,body{height:100%}
    body{
      margin:0;
      font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica,Arial,"PingFang SC","Microsoft YaHei",sans-serif;
      color:var(--ink);
      background: linear-gradient(180deg,var(--bg1),var(--bg2));
    }
    .page{
      min-height:100vh;
      display:flex;
      flex-direction:column;
      align-items:center;
    }
    .topbar{
      position:sticky; top:0;
      display:flex; align-items:center; justify-content:center;
      height:64px; width:100%;
      font-weight:800; font-size:22px;
    }
    .back{
      position:absolute; left:14px; top:14px;
      width:36px; height:36px; border-radius:999px;
      display:grid; place-items:center;
      background:transparent; border:none; cursor:pointer;
    }
    .back svg{width:24px; height:24px}
    .card{
      width:min(520px,92%);
      background:var(--card);
      border-radius:var(--radius);
      padding:18px 18px 14px;
      margin-top:8px;
      box-shadow:0 6px 16px rgba(0,0,0,.05);
    }
    .label{
      font-weight:700; font-size:16px; margin:4px 0 10px;
    }
    textarea{
      width:100%;
      min-height:96px;
      border:1.5px solid rgba(0,0,0,.15);
      border-radius:12px;
      padding:12px 14px;
      font-size:16px;
      outline:none;
      resize:vertical;
      background:#fff;
    }
    .actions{margin-top:12px; display:flex; gap:10px}
    .btn{
      display:inline-flex; align-items:center; gap:8px;
      border:none; cursor:pointer;
      padding:10px 14px 10px 10px;
      background:var(--btn); color:var(--btn-text);
      border-radius:12px; font-weight:700;
      box-shadow:0 6px 14px rgba(30,91,80,.25);
    }
    .btn .iconwrap{
      width:28px; height:28px; border-radius:999px;
      background:#0c3f37; display:grid; place-items:center;
    }
    .btn svg{width:16px; height:16px; fill:var(--btn-text)}
    
    /* Result display styles */
    .result-card{
      width:min(520px,92%);
      background:var(--card);
      border-radius:var(--radius);
      padding:18px;
      margin-top:16px;
      box-shadow:0 6px 16px rgba(0,0,0,.05);
      border-left:4px solid var(--success);
    }
    .no-result{
      border-left-color:var(--warning);
      color:#856404;
    }
    .result-title{
      font-weight:700;
      font-size:18px;
      margin-bottom:12px;
      color:var(--ink);
    }
    .result-content{
      font-size:16px;
      line-height:1.5;
      color:var(--ink);
    }
    
    /* bottom nav */
    .nav{
      position:fixed; left:0; right:0; bottom:0;
      height:64px; background:var(--nav);
      display:flex; justify-content:space-around; align-items:center;
      padding:6px 14px;
    }
    .nav a{
      width:44px; height:44px; border-radius:12px;
      display:grid; place-items:center; text-decoration:none; color:#0b0b0b;
      opacity:.92;
    }
    .nav a.active{background:rgba(255,255,255,.28); backdrop-filter: blur(2px)}
    .nav svg{width:24px; height:24px; fill:#0b0b0b}
    .spacer{height:80px}
  </style>
</head>
<body>
  <div class="page">
    <header class="topbar">
      <button class="back" onclick="history.back()"
              aria-label="Back">
        <svg viewBox="0 0 24 24"><path d="M15.41 7.41 14 6l-6 6 6 6 1.41-1.41L10.83 12z"/></svg>
      </button>
      Identification
    </header>

<%            
String name = request.getParameter("q");
String searchResult1 = "";
String searchResult2 = "";
boolean hasResult = false;
String debugInfo = "";
Connection con = null;
Statement sql = null; 
ResultSet rs = null;
int max = 0;

if (name != null && !name.trim().isEmpty()) {
    try {
        debugInfo += "Searching for: '" + name + "'<br>";
        debugInfo += "Trimmed search term: '" + name.trim() + "'<br>";
        Class.forName("com.mysql.cj.jdbc.Driver"); // 使用新版本驱动
        debugInfo += "Driver loaded successfully<br>";
        
        String url = "jdbc:mysql://127.0.0.1:3306/e-waste?serverTimezone=Asia/Shanghai&characterEncoding=utf8";
        String user = "root";
        String password = "123456";
        
        con = DriverManager.getConnection(url, user, password);
        debugInfo += "Database connected successfully<br>";
        
        sql = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);
        rs = sql.executeQuery("SELECT * FROM recycling_items ORDER BY item_name");
        
        // Count rows first
        int rowCount = 0;
        while(rs.next()) {
            rowCount++;
        }
        debugInfo += "Found " + rowCount + " items in database<br>";
        
        if (rowCount > 0) {
            rs.beforeFirst(); // Reset to beginning
            item[] items = new item[rowCount];
            int index = 0;
            
            while(rs.next() && index < rowCount) {
                String itemName = rs.getString("item_name");
                String itemParts = rs.getString("item_parts"); 
                String itemPlace = rs.getString("item_place");
                
                // Clean the data (remove extra spaces, etc.)
                if (itemName != null) itemName = itemName.trim();
                if (itemParts != null) itemParts = itemParts.trim();
                if (itemPlace != null) itemPlace = itemPlace.trim();
                
                items[index] = new item(itemName, itemParts, itemPlace);
                debugInfo += "Item " + (index+1) + ": name='" + itemName + "', parts='" + itemParts + "', place='" + itemPlace + "'<br>";
                index++;
            }
            
            // Search for matching item
            debugInfo += "<br>Starting search comparison:<br>";
            String searchTerm = name.trim().toLowerCase();
            debugInfo += "Search term (lowercase): '" + searchTerm + "'<br>";
            
            for(int i = 0; i < index; i++) {
                String dbItemName = items[i].getname();
                if (dbItemName != null) {
                    String dbItemNameLower = dbItemName.toLowerCase();
                    debugInfo += "Comparing '" + searchTerm + "' with '" + dbItemNameLower + "' - ";
                    
                    if(searchTerm.equals(dbItemNameLower)) {
                        hasResult = true;
                        searchResult1 = items[i].getparts();
                        searchResult2 = items[i].getplace();
                        debugInfo += "EXACT MATCH FOUND!<br>";
                        break;
                    } else {
                        debugInfo += "no match<br>";
                    }
                }
            }
            
            // If no exact match, try partial match
            if (!hasResult) {
                debugInfo += "<br>No exact match found. Trying partial match...<br>";
                for(int i = 0; i < index; i++) {
                    String dbItemName = items[i].getname();
                    if (dbItemName != null && dbItemName.toLowerCase().contains(searchTerm)) {
                        hasResult = true;
                        searchResult1 = items[i].getparts();
                        searchResult2 = items[i].getplace();
                        debugInfo += "Partial match found: '" + dbItemName + "'<br>";
                        break;
                    }
                }
            }
        } else {
            debugInfo += "No items found in database table!<br>";
        }
        
    } catch(Exception e) {
        debugInfo += "Database error: " + e.getMessage() + "<br>";
        debugInfo += "Stack trace: " + java.util.Arrays.toString(e.getStackTrace()) + "<br>";
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (sql != null) sql.close();
            if (con != null) con.close();
            debugInfo += "Database connection closed<br>";
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
%>
		    
    <main style="width:100%; display:flex; flex-direction:column; align-items:center;">
      <form class="card" action="identification.jsp" method="get" autocomplete="off">
        <div class="label">What you would like to recycle:</div>
        <textarea name="q" placeholder="Type an item name…"><%= name != null ? name : "" %></textarea>
        <div class="actions">
          <button class="btn" type="submit">
            <span class="iconwrap">
              <svg viewBox="0 0 24 24"><path d="M15.5 14h-.79l-.28-.27a6.471 6.471 0 0 0 1.57-4.23C15.99 6.01 13.98 4 11.5 4S7 6.01 7 9.5 9.01 15 11.5 15c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l4.25 4.25 1.49-1.49L15.5 14zm-4 0C9.01 14 7 11.99 7 9.5S9.01 5 11.5 5 16 7.01 16 9.5 13.99 14 11.5 14z"/></svg>
            </span>
            <span>Search for information</span>
          </button>
        </div>
      </form>

      <!-- Display search results -->
      <% if (name != null && !name.trim().isEmpty()) { %>
        <div class="result-card <%= hasResult ? "" : "no-result" %>">
          <div class="result-title">
            <%= hasResult ? "Recycling Information" : "No Information Found" %>
          </div>
          <div class="result-content">
            <% if (hasResult) { %>
              <strong>Item:</strong> <%= name %><br><br>
              <strong>Recycling Guide:</strong><br>
              <%= name %> contains <%= searchResult1 %>, the nearest recycle place is <%= searchResult2 %>
            <% } else { %>
              Sorry, no recycling information found for "<%= name %>". Please try other keywords or contact customer service for assistance.
            <% } %>
            
            <!-- Debug information -->
            <% if (name != null && !name.trim().isEmpty()) { %>
              <hr style="margin: 20px 0;">
              <strong>Debug Information:</strong><br>
              <%= debugInfo %>
            <% } %>
          </div>
        </div>
      <% } %>

      <div class="spacer"></div>
    </main>
  </div>

  <!-- Bottom navigation -->
  <nav class="nav" role="navigation" aria-label="Primary">
    <a href="home.jsp" title="Home" aria-label="Home">
      <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
    </a>
    <a href="achievements.jsp" title="Achievements" aria-label="Achievements">
      <svg viewBox="0 0 24 24"><path d="M17 3H7v4H3v3a5 5 0 0 0 5 5h1.1A5.002 5.002 0 0 0 12 19H9v2h6v-2h-3a5.002 5.002 0 0 0 2.9-4H16a5 5 0 0 0 5-5V7h-4V3zm-2 4V5h2v2h-2zM5 9V7h2v2a3 3 0 0 1-2 0zm14 0a3 3 0 0 1-2 0V7h2v2z"/></svg>
    </a>
    <a class="active" href="identification.jsp" title="Recycle" aria-label="Recycle">
      <svg viewBox="0 0 24 24"><path d="M16.5 6l-1.41 1.41 1.09 1.09L12 12l-2.18-2.18 1.09-1.09L9.5 6 6 9.5l3.41 3.41L7.91 14.4 9 15.5 12 12.5l3 3 .91-.91L14.59 13 18 9.5 16.5 6z"/></svg>
    </a>
    <a href="guides.jsp" title="Guides" aria-label="Guides">
      <svg viewBox="0 0 24 24"><path d="M7 5h14v2H7zM3 7h2v12H3zM7 9h14v2H7zM7 13h14v2H7zM7 17h14v2H7z"/></svg>
    </a>
    <a href="profile.jsp" title="Profile" aria-label="Profile">
      <svg viewBox="0 0 24 24"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5zm0 2c-4.33 0-8 2.17-8 5v1h16v-1c0-2.83-3.67-5-8-5z"/></svg>
    </a>
  </nav>
</body>
</html>
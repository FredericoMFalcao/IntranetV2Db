-- Platform Graphical User Interface (GUI) Javascript Functions
-- Description: Lists all the global javascript functions available at the browser programming environment
--              (1) The Code includes is ONLY the javascript code inside the function, not the wrapper "function xxx (...) { ... }"

CREATE TABLE PLT_GUI_Javascript (
 _id 			        int(11) NOT NULL AUTO_INCREMENT,
 lastUpdate 	   timestamp NOT NULL DEFAULT current_timestamp(),
 Namespace 		   varchar(255) DEFAULT NULL,
 FuncName 		    varchar(255) NOT NULL,
 InputArgs_json longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
 Description 	  varchar(255) DEFAULT NULL,
 Code 			       text NOT NULL,
 PRIMARY KEY (_id),
 UNIQUE KEY (Namespace,FuncName)
);

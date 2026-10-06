g_mysql_Init() {
    DB::query_fmt_cache = map_new();
    mysql_log(ERROR | WARNING);
    new dbHost[128], dbUser[128], dbPassword[128], dbDB[128];
  
    if( !Env_Has("MYSQL_USER") ||
        !Env_Has("MYSQL_PASSWORD") ||
        !Env_Has("MYSQL_HOST") ||
        !Env_Has("MYSQL_DATABASE")
    ) {
      printf("NO DATABASE ENV FOUND");
      SendRconCommand("exit");
    }

    Env_Get("MYSQL_USER", dbUser);
    Env_Get("MYSQL_PASSWORD", dbPassword);
    Env_Get("MYSQL_HOST", dbHost);
    Env_Get("MYSQL_DATABASE", dbDB);
    MainConn = mysql_connect(dbHost, dbUser,dbPassword, dbDB);
    printf("[MySQL] (MainConn) Connecting to database...");
    if(mysql_errno(MainConn) != 0) {
        printf("[MySQL] (MainConn) Fatal Errro! Could not connect to mysql databases");
        printf("[MySQL] Please check the credentials or server has already started.");
        printf("[MySQL] ERR_NO: %d", mysql_errno(MainConn));
        SendRconCommand("exit");
    } else { 
        printf("[MySQL] (MainConn) Connection success.");
        InitializeGamemode();
    }
}

stock g_mysql_Exit() {
    mysql_close(MainConn);
    map_delete(DB::query_fmt_cache);
}


forward OnQueryFinish(resultid, extraid, handleid);
public OnQueryFinish(resultid, extraid, handleid) {
    // new rows, fields, value;
    return 1;
}

public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle) {
    printf("[MySQL] Query Error = (ErrID: %d)", errorid);
    printf("[MySQL] Check mysql_log.txt to review the query that threw error.");
    if(errorid == 2013 || errorid == 2014 || errorid == 2006 || errorid == 2027 || errorid == 2055)	{
		print("[MySQL] Connection Error Detected in Threaded Query");
		//mysql_query(query, resultid, extraid);

		format(szMiscArray, sizeof(szMiscArray), "MYSQL [%d]: %d, %s, in callback: %s.", iErrorID, errorid, error, callback);
	}
	else format(szMiscArray, sizeof(szMiscArray), "MYSQL (THREADED) [%d]: %d, %s, in callback: %s.", iErrorID, errorid, error, callback);

    iErrorID++;
    // Send Notification Here
}

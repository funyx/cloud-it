# database <- config::get("database")

# con <- DBI::dbConnect(odbc::odbc(),
#     Driver = database$driver,
#     Server = database$server,
#     UID = database$uid,
#     PWD = database$pwd,
#     Port = database$port,
#     Database = database$database
# )
# on.exit(dbDisconnect(con))

# copy_to(con, mtcars)
# mtcars2 <- tbl(con, "mtcars")
# dput(mtcars2, stderr())
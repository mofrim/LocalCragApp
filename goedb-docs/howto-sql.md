# howto SQL

- start repling with the db: `psql -h localhost localcrag localcrag_user`
- list all tables in the db: `\d`
- list the columns an types of a table: `\d tablename`
- select all from a table that is null:
  `SELECT * FROM table WHERE col is NULL;`
- select all from table where something matches some other string:
  `SELECT * FROM table WHERE col = 'string'`
  (!! mind the single quotes here !!)

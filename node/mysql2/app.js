const mysql = require('mysql2/promise');
const env = require('dotenv').config({ path: "../../.env" });

const db = async() => {
    try {
        //db connection
        let connection = await mysql.createConnection({
            host: process.env.host,
            user: process.env.user,
            port: process.env.port,
            password: process.env.password,
            database: process.env.database 
        })

        // select query
        let [rows, feilds] = await connection.query('select * from st_info');
        console.log(rows);

        // make insert data
        let data = {
            st_id:"202499",
            name: "Moon",
            dept:"Computer"
        }

        // inserted data's id
        let insertId = data.st_id;

        // insert query
        [rows, feilds] = await connection.query("insert into st_info set ?", data);
        console.log("\nData is inserted : " + insertId);

        //select query
        [rows, feilds] = await connection.query("select * from st_info where st_id =?", [insertId]);
        console.log(rows);

        //update query
        [rows, feilds] = await connection.query("update st_info set DEPT = ? where ST_ID = ?", ["Game", insertId]);
        console.log("\nData is updated : " + insertId);

        //select * query for updated data
        [rows, feilds] = await connection.query("select * from st_info where st_id =?", [insertId]);
        console.log(rows);

        //delete query
        [rows, feilds] = await connection.query("delete from st_info where ST_ID = ?", [insertId]);
        console.log("\nData is deleted : " + insertId);

        //select * query for deleted data
        [rows, feilds] = await connection.query("select * from st_info where st_id =?", [insertId]);
        console.log(rows);

    } catch (error) {
        console.log(error);
    }
}

db();

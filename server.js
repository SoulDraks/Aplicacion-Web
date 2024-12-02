const express = require('express');
const mysql = require('mysql');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
    host: 'autorack.proxy.rlwy.net:3306', 
    user: 'SoulDraks', // Pone tu usuario
    password: 'soulcito', // Pone la contraseña de tu usuario
    database: 'tiendita', // Selecciona la base de datos la cual usaras en las consultas :D.
    port: 3306,
    dateStrings: true
});

db.connect(err => {
    if (err) throw err;
    console.log('Conectado a MySQL.');
});

app.post('/query', (req, res) => {
    let sql = req.body.sql;
    const values = req.body.values || [];
    sql = sql.replace(/\n/g, ' ').replace(/\t/g, ' ');
  
    db.query(sql, values, (err, results) => {
        if (err) {
            console.error("Error en la consulta:", err);
            return res.status(500).json({ error: 'Error al ejecutar la consulta.' });
        }
        console.log("Consulta ejecutada:", sql);
        console.log("Valores:", values);
        res.json(results);
    });
  });

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Servidor escuchando en el puerto ${port}`);
});

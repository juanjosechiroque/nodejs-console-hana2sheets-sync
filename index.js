import fs from "fs/promises";
import hanaClient from '@sap/hana-client';
import config from "./config.js";
import { google } from "googleapis";

const hanaConfig = {
    host: config.HANA.HOST,
    port: config.HANA.PORT,
    uid: config.HANA.USER,
    pwd: config.HANA.PASSWORD,
};

const googleAuth = new google.auth.JWT(
    config.GOOGLE.SERVICE_ACCOUNT_EMAIL,
    null,
    config.GOOGLE.SERVICE_ACCOUNT_PRIVATE_KEY.replace(/\\n/g, '\n'),
    'https://www.googleapis.com/auth/spreadsheets'
);

const GOOGLE_SHEET_ID = config.GOOGLE.GOOGLE_SHEET_ID
const SHEET_RANGE = config.GOOGLE.GOOGLE_SHEET_PAGE;

try {
  const connection = hanaClient.createConnection(hanaConfig);
  const sheetsService = await google.sheets({ version: 'v4', auth: googleAuth});
  let offset = 0;
  let rangeStart = 1;

  connection.connect(hanaConfig);
  console.log("conexion a hana buena");

  console.time('Todo el proceso');
  while (true) {

    console.time('Consulta HANA');

    const sqlQuery = await fs.readFile('./query.sql', 'utf8');
    const rows = await connection.execute(`${sqlQuery} LIMIT 2000 OFFSET ${offset}`);
    console.timeEnd('Consulta HANA');

    if (rows.length === 0) {
      console.log('No more data to fetch.');
      break;
    }

    const data = rows.map(row => Object.values(row));

    if (offset === 0) {
      const headers = Object.keys(rows[0]);
      data.unshift(headers);
    }

    console.time('Envío a Google Sheets');
    await sheetsService.spreadsheets.values.update({
      spreadsheetId: GOOGLE_SHEET_ID,
      range: `${SHEET_RANGE}!A${rangeStart}`,
      valueInputOption: 'USER_ENTERED',
      resource: { values: data }
    });
    console.timeEnd('Envío a Google Sheets');

    offset += rows.length;
    rangeStart += rows.length;
  }
  console.log('Data sent to Google Sheets successfully.');
  console.timeEnd('Todo el proceso');
} catch (err) {
    console.log (err);
}

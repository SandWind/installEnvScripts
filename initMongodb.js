// initMongodb.js
db.adminCommand('listDatabases');
db = db.getSiblingDB('admin');
// db.createUser({ user: "sandwind", pwd: "diablo", roles: [{ role: "userAdminAnyDatabase", db: "admin" }] });
db.adminCommand(
    {
      createUser: "sandwind",
      pwd: passwordPrompt(),  // or <cleartext password>
      roles: [
        { role: "userAdminAnyDatabase", db: "admin" }
      ]
    }
  );
db.auth( 
    {
      user:"sandwind",
      pwd:"diablo" 
    }
);
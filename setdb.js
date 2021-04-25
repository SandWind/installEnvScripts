db.createUser({ user: "test", pwd: "testxxxxxx", roles: [{ role: "readWrite", db: "testdb" }] })
 //生成链接如下 mongodb://test:diablo@localhost/testdb

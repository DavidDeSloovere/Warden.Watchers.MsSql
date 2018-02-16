# Warden MSSQL Watcher

![Warden](http://spetz.github.io/img/warden_logo.png)

**OPEN SOURCE & CROSS-PLATFORM TOOL FOR SIMPLIFIED MONITORING**

**[getwarden.net](http://getwarden.net)**

|Branch             |Build status                                                  
|-------------------|-----------------------------------------------------
|master             |[![master branch build status](https://api.travis-ci.org/warden-stack/Warden.Watchers.MsSql.svg?branch=master)](https://travis-ci.org/warden-stack/Warden.Watchers.MsSql)
|develop            |[![develop branch build status](https://api.travis-ci.org/warden-stack/Warden.Watchers.MsSql.svg?branch=develop)](https://travis-ci.org/warden-stack/Warden.Watchers.MsSql/branches)

**MsSqlWatcher** can be used either for simple database monitoring (e.g. checking if a connection can be made) or more advanced one which may include running a specialized query.

### Installation:

Available as a **[NuGet package](https://www.nuget.org/packages/Warden.Watchers.MsSql)**. 
```
dotnet add package Warden.Watchers.MsSql
```

### Configuration:

 - **WithQuery()** - executes the specified query on a selected database.
 - **WithTimeout()** - timeout after which the invalid result will be returned.
 - **EnsureThat()** - predicate containing a received query result of type *IEnumerable<dynamic>* that has to be met in order to return a valid result.
 - **EnsureThatAsync()** - async  - predicate containing a received query result of type *IEnumerable<dynamic>* that has to be met in order to return a valid result
 - **WithConnectionProvider()** - provide a  custom *IDbConnection* which is responsible for making a connection to the database.
 - **WithMsSqlProvider()** - provide a  custom *IMsSql* which is responsible for executing a query on a database based on the *IDbConnection*.

**MsSqlWatcher** can be configured by using the **MsSqlWatcherWatcherConfiguration** class or via the lambda expression passed to a specialized constructor.

Example of configuring the watcher via provided configuration class:
```csharp
var configuration = MsSqlWatcherConfiguration
    .Create(@"Data Source=.\sqlexpress;Initial Catalog=MyDatabase;Integrated Security=True")
    .WithQuery("select * from users where id = @id", new Dictionary<string, object> {["id"] = 1 })
    .EnsureThat(users => users.Any(user => user.Name == "admin"))
    .Build();
var mssqlWatcher = MsSqlWatcher.Create("My MSSQL watcher", configuration);

var wardenConfiguration = WardenConfiguration
    .Create()
    .AddWatcher(mssqlWatcher)
    //Configure other watchers, hooks etc.
```

Example of adding the watcher directly to the **Warden** via one of the extension methods:
```csharp
var wardenConfiguration  = WardenConfiguration
    .Create()
    .AddMsSqlWatcher(@"Data Source=.\sqlexpress;Initial Catalog=MyDatabase;Integrated Security=True", cfg =>
    {
        cfg.WithQuery("select * from users where id = @id", new Dictionary<string, object> {["id"] = 1})
           .EnsureThat(users => users.Any(user => user.Name == "admin"));
    })
    //Configure other watchers, hooks etc.
```

Please note that you may either use the lambda expression for configuring the watcher or pass the configuration instance directly. You may also configure the **hooks** by using another lambda expression available in the extension methods.

### Check result type:
**MsSqlWatcher** provides a custom **MsSqlWatcherCheckResult ** type which contains additional values.

```csharp
public class MsSqlWatcherCheckResult : WatcherCheckResult
{
    public string ConnectionString { get; }
    public string Query { get; }
    public IEnumerable<dynamic> QueryResult { get; }
}
```
### Custom interfaces:
```csharp
public interface IMsSql
{
    Task<IEnumerable<dynamic>> QueryAsync(IDbConnection connection, string query,
        IDictionary<string, object> parameters, TimeSpan? timeout = null);
}
```

**IMsSql** is responsible for executing the query on a database. It can be configured via the *WithMsSqlProvider()* method. By default it is based on the **[Dapper](https://github.com/StackExchange/dapper-dot-net)**.
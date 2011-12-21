# Fatalistic

Fatalistic is a Ruby gem that adds table-level locking to Active Record.

## Table locks

Table-level locks can be used to restrict read and write access to a table.
Neither Postgres nor MySQL currently support truly serializabile transactions,
so table locks are sometimes necessary to reliably avoid the "phantom record"
problem. See this [Wikipedia
article](http://en.wikipedia.org/wiki/Isolation_\(database_systems\)#Isolation_Levels.2C_Read_Phenomena_and_Locks)
for more details.

The [MySQL
docs](http://dev.mysql.com/doc/refman/5.1/en/lock-tables-restrictions.html) show
a classic usage scenario for table locking:

    LOCK TABLES trans READ, customer WRITE;
    SELECT SUM(value) FROM trans WHERE customer_id=some_id;
    UPDATE customer
      SET total_value=sum_from_previous_statement
      WHERE customer_id=some_id;
    UNLOCK TABLES;


Table-level locks are generally best avoided when possible because of their
potential impact on performance. MySQL/Innodb's locking implementation is also
clunky and fraught with bizarre behaviors, [particularly when used with
transactions](http://dev.mysql.com/doc/refman/5.1/en/lock-tables-and-transactions.html).
Before relying on table locks, see if there's some other way to accomplish your
goal. However, they can be useful when used sparingly.

## Doesn't Active Record already support locking?

Active Record supports row-level locking, but not table locking.

If you do something like `Person.lock` with Active Record will emit the query
`SELECT * FROM people FOR UPDATE`. This is bad for performance because if you
have a lot of rows, it's going to be very slow. It's also nearly useless,
because it still doesn't prevent new records from being inserted. Finally, it's
foolish because if you want to lock every row in a table, it makes much more
sense to lock the table itself.

Active Record comes with 2 locking modules: optimistic and pessimistic. Since
this locking mode is the most "extreme" of the three, I've named it
"fatalistic."

## What Fatalistic does

MySQL and Postgres use the same row locking syntax, but quite different table
locking syntax. This library provides the abstraction needed to use them both
with Active Record. SQLite does not support table level locking, so the methods
provided here are just no-ops with SQLite.

Fatalistic changes the behavior of the top-level `lock` method so that
`Person.lock` will lock the entire table, but `Person.where(...).lock` will
continue to lock just the selected records.

## Example

    class Person < ActiveRecord::Base
    end

    Person.lock do
      # your code here
    end


## Getting it

Just install with RubyGems:

    gem install fatalistic

The source code is [on Github](https://github.com/bvision/fatalistic).

## License

Copyright (c) 2011-2012 Norman Clarke and Business Vision SA

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

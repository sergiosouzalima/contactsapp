Contacts App
================

Website using Text File as Database.

Ruby on Rails
-------------

This application was building using:

- Ruby 2.2.1
- Rails 4.2.3

To know more about Rails [Installing Rails](http://railsapps.github.io/installing-rails.html).

What is it?
---------------

Contacts App is an application that uses a single text file as a database to store contacts data.

This website was built to know how to deal with a text file delimited with semicolon as a database.

Several problems had to be resolved such as 'How can I generate an id?', the "link_to" Rails helper
that works well when using relational databases and many others.

Others solutions had to be implemented to this specific situation like create a new method
to represent a contact data update: it was created a deletion followed by a new record creation
instead of a simple relational database update.

**This website is just a drill.**
This website is an exercise.
Don't use it in production environment, but if you do it
and if it fits in your needs, please let me know :-)

**Commands**
There's a command that you can use to feed contact data to db/development.txt file:

- $ rake text_file:seed

You can run tests using Rspec:

- $ rspec -fd

**The idea is not to use databases**
Therefore, if you are interested, fork it, improved it and let me know how we can turn it for a
better use, still not using relational databases or other kinds of databases.


Thanks.


# README

MeaCal.tool is a tool for converting Gregorian dates to a fixed month format, heavily inspired by https://wiki.xxiivv.com/site/arvelie.html. 

- The year counts from 00 to 99 using a base year defined in a configuration file.
- Each year is divided into 26 months of 14 days each, where each month is assigned a character 'A' to 'Z'. 
- Each month has 14 days number 00 to 13. 
- The last day of the year is set to +00.
- The leap year day (02-29) is set to +01.

So if the base year is 2000, 2021-06-09 converts to 21L05.

The configuration file can be found in ~/.config/meacal/meacal.config.

Each line holds one configuration item on the following format. 

[name]:prefix:[prefix]|year:[base_year]

Configuration item example.

millenium:prefix:Y|year:2000

Usage: mecal.tool name date

Example of usage.

./meacal.tool millenium 2021-06-09
A21L05


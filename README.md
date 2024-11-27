# Eric's Advent of Code 2024 Solutions

## The Blog

For the last four years, I've blogged my approaches to the Advent of Code puzzles on my
[personal site](https://www.ericburden.work/blog/). Assuming I hold true to form, each 
blog post will include code and commentary on my thinking behind the approach, my thoughts
about the puzzles, and vain attempts at wit.

## Project Structure

This year, I'm using Gleam! Much like Rust, Julia, and Kotlin in prior years, Gleam is a
new language for me. Given the popularity of the language and the fact that it might
mean I don't ever have to write JavaScript again (yeah, I know, not likely), I'm 
excited to learn my first language on the BEAM.

```
<project root>
├─src
│ └─day##
│   ├─day##.gleam
│   ├─parse.gleam
│   ├─part1.gleam
│   └─part2.gleam
├─test
│ └─day##
│   ├─examples
│   │ ├─example1.txt
│   │ └─example2.txt
│   ├─input
│   │ └─input.txt
│   └day##_test.gleam
├─test
├─setup-day
├─gleam.toml
├─manifest.toml
└─README.md
```

There are a few organizational notes to point out here:

- The code for each day is broken up into three files. `day##.gleam` is used to define
  the Input and Output types and to hold the relative file paths to the various input
  text files. `parse.gleam` holds the code for parsing the input files. `part1.gleam`
  and `part2.gleam` hold the code for solving the two parts of the day's puzzle.
- Each day's input and examples are stored in their own text files and are parsed from
  there. I tend to avoid hard-coding inputs whenever I can, preferring to parse them
  from text.
  
## Usage
  
One of the nice things about Gleam is the tooling. Any dependencies can be added with
`gleam add` and `gleam test` runs all the tests. I'd like to be able to run each day's
tests individually, but maybe that's something I'll need to write my own CLI for.
 
This project also include a `setup-day` bash script that leverages the 
[`aoc-cli`](https://github.com/scarvalhojr/aoc-cli) Rust CLI tool to create
the days' code and test files, download the input files, name them, and
place them in the correct folder. The script can be invoked as 
`setup-day {day} {year}`, where the year argument is optional.


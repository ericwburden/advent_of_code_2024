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
├─ inputs
│  └─ day##/input.txt     # puzzle input files (not committed to GitHub)
├─ src
│  ├─ common/             # shared helpers (grid2d, types, etc.)
│  └─ day##/
│     ├─ day##.gleam      # defines Input/Output types and input_path
│     ├─ parse.gleam      # parsing logic
│     ├─ part1.gleam      # solution for Part 1
│     ├─ part2.gleam      # solution for Part 2
│     └─ run.gleam        # runner with expected answers and self-checks
├─ test                   # tests are for examples only
│  └─ day##/
│     ├─ day##_test.gleam # unit tests
│     └─ examples/        # sample example input files
├─ setup-day              # helper script to scaffold new days
├─ gleam.toml             # Gleam project configuration
├─ manifest.toml          # Dependency manifest
└─ README.md
```

A few notes:

- Each day’s code is broken up into three core files plus a run.gleam.
  - day##.gleam: holds types and the input path.
  - parse.gleam: parsing logic.
  - part1.gleam / part2.gleam: puzzle solutions.
  - run.gleam: self-checks against expected answers.
- All puzzle inputs live under the top-level inputs/ directory. These are not committed to GitHub, per AoC guidelines.
- Example inputs and tests live under test/day##/examples/.
  
## Usage
  
One of the nice things about Gleam is the tooling. Any dependencies can be added with
`gleam add` and `gleam test` runs all the tests. I'd like to be able to run each day's
tests individually, but maybe that's something I'll need to write my own CLI for.
 
This project also include a `setup-day` bash script that leverages the 
[`aoc-cli`](https://github.com/scarvalhojr/aoc-cli) Rust CLI tool to create
the days' code and test files, download the input files, name them, and
place them in the correct folder. The script can be invoked as 
`setup-day {day} {year}`, where the year argument is optional.

## Running Solutions

### Run an Individual Day

Each day folder contains a run.gleam file with a main function that checks the
solutions for that day against the expected results.

To run, for example, Day 03:  `gleam run -m day03/run`

This will parse the day’s input, run both parts, and print ✅ or 🛑 depending on whether
the results match the expected answers.

### Run All Days

At the top level, there’s an orchestrator module: `src/advent_of_code_2024.gleam`.
This imports each dayxx/run and calls their main functions in order.

To run all solved days in sequence: `gleam run -m advent_of_code_2024`

This will execute each run.gleam and print results for every available day.


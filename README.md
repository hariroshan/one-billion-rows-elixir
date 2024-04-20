# OneBillion

Attempting One billion rows challenge in elixir `https://github.com/gunnarmorling/1brc`

For 100 million rows, it took:
```sh
./one_billion  226.51s user 38.14s system 620% cpu 42.669 total
```

## Installation

Install Java 21 using

```sh
apt install openjdk-21
```

Clone the repo `https://github.com/gunnarmorling/1brc`

```sh
git clone https://github.com/gunnarmorling/1brc
```

Build the `1brc` project and generate `measurements.txt` file

```sh
cd 1brc
./mvnw clean verify
./create_measurements.sh 100000000 # 100_000_000
```
To run this project

```sh
git clone https://github.com/hariroshan/one-billion-rows-elixir

# Move the measurements.txt to the project root
mv 1brc/measurements.txt one-billion-rows-elixir/

cd one-billion-rows-elixir
mix deps.get && mix compile

# You can use iex -S mix too
MIX_ENV=prod mix "escript.build"

time ./one_billion
```

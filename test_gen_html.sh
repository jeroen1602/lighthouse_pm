#! /bin/bash

flutter test --coverage || exit 1
# Filter out the generated untestable classes
lcov --remove ./coverage/lcov.info '**/*.g.dart' 'lib/data/tables/*.dart' -o ./coverage/lcov-filtered.info || exit 2

# Generate the html
genhtml -o coverage/out ./coverage/lcov-filtered.info

echo "Html can be found in ./coverage/out/index.html"


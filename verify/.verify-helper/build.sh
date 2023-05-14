filename="verify/$1"; shift
output="verify/$1"; shift

cd ../

echo -e "\e[32mINFO\e[m:build.sh:Building Crystal project ${filename}..."
crystal build "$filename" -o "${output}" --error-trace $@ || exit 1

cd verify/

echo -e "\e[32mINFO\e[m:build.sh:Building completed!"

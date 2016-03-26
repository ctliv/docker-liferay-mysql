echo "1 - \$(dirname \$0)"
echo $(dirname $0)
echo -e "\n2 - \$(pwd)/\$(dirname \$0)"
echo $(pwd)/$(dirname $0)
echo -e "\n3 - \$(realpath \$0)"
echo $(realpath $0)
echo -e "\n4 - \$(dirname \$(realpath \$0))"
echo $(dirname $(realpath $0))
echo -e "\n5 - \$(readlink -f \$0)"
echo $(readlink -f $0)
echo -e "\n6 - \$(dirname \$(readlink -f \$0))"
echo $(dirname $(readlink -f $0))

delimiter=' - - -'
vars_file=./vars
out_file=recap
touch $vars_file $out_file
temp1=/tmp/temp1
temp2=/tmp/temp2

equal="============================================================"
asterisk="************************************************************"

get_input()
{
    key=$1
    column=$2
    msg=$3
    eval "value=$(echo \$$$key)"
    value=$(echo $value | sed -e "s/$delimiter//g" -e 's/  */ /g' )
    
    [ "X`echo $value | grep -i "~~"`" != X ]&& msg_error "$msg"
    
    value=$(echo "$value" | cut -d" " -f $column)
    eval "$key=$value"
}

check_parameters_input()
{
    num_para=$#
    [ $1 = "EXAMPLE:" ]&& msg_error "Please enter new parameters this is only example for help"
    [ $num_para = $num_parameters ]|| msg_error "Number of input parameters need to be '$num_parameters' '$dns_para'"
}

set_parameters()
{
    echo >> $vars_file
    i=1
    for para in $*; do
        eval "echo para$i=$para" >> $vars_file
        i=$(expr $i + 1)
    done
}

set_var()
{
    [ X$1 = X ]&& msg_error "No paramter to insert to function"

    sed  -i "s/${1}=.*//" $vars_file
    eval "echo $1=\\\$$1" >> $vars_file
    check_vars_file
    .  $vars_file
}

get_vars()
{
    check_vars_file
    . $vars_file
}

check_if_exists()
{
    msg="Parameter '$var_key' includes empty value"
    var_key=$1
    msg=$2
    
    eval var_value=\\\$$var_key
    echo "$1='$var_value'"
    if [ -z $var_value ]; then
        msg_error "$msg"
    fi
}

check_vars_file()
{
    if grep -q '=$' $vars_file; then
        show_file $vars_file
        msg_error "Some parameters in file '$vars_file' do not have value"
    fi
}

msg()
{
set +x
if [ -z $2 ]; then
    echo "\n$1\n"
else
    echo "\n$1"
    case $2 in
    asterisk) echo "$asterisk\n";;
    equal) echo "$equal\n";;
    esac
fi
set -x
}

msg_error()
{
    msg "***ERROR: $1" asterisk
    exit 1
}

msg_fun()
{
    msg "$1" equal
}

show_file()
{
    set +x
    file=$1
    out=$2
    [ ! -z $out ]&& out=">> $out"
    eval echo  $out
    eval "echo \"Show file '$file'\" $out"
    eval "echo \"$equal\" $out"
    eval "cat $file $out"
    eval "echo \"$equal\" $out"
    eval echo  $out
    set -x
}

pad_loop()
{
    for key in $*; do
        para=$(echo $key | awk -F'-' '{print \$1}')
        num_char=$(echo $key | awk -F'-' '{print \$2}')
        
        eval "para_str=\\\$$para"
        num_value=$(echo ${#para_str})
        [ $num_value -ge $num_char ]&& num_char=$(expr $num_value + 2)
        eval "echo ${para}_pad=\\\$${para}-XXXXXXXXXXXXXXXXXXXXXX" | sed 's/-X//' > $temp1
        pr=$(cat $temp1 | awk -F'=' '{print \$1}')
        str=$(cat $temp1 | awk -F'=' '{print \$2}' | cut -c1-$num_char)
        eval "echo ${pr}=${str}" >> $vars_file
    done
}

header()
{
    echo "Parameters for job: '$JOB_NAME' number '${BUILD_ID}'">> $out_file
    for key in $*; do
        eval "value=$(echo "\\\$$key")"
        echo "${key}='$value'" >> $out_file
    done
    echo "$equal" >> $out_file
}

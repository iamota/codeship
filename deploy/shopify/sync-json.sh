#!/bin/bash
# Move Assets between Shopify Themes
# ===================================================================

# Abort on Error
set -e
echo ""


# ===================================================================
# Define Colours for Formatting
NC='\033[0m' # No Color
RED='\033[0;31m'
LTRED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'


# ===================================================================
# Capture Inputs
# Supports: --source=dev --destination=prod
# Defaults: --source=localhost --destination=localhost

# Set defaults "localhost"
source_env=localhost
destination_env=localhost
skip_config=false
skip_schema=${skip_config}
skip_data=${skip_config}
skip_locales=false
skip_templates=false
allow_live=false
replace_src=false
force=false
verbose=false

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this
# separately; see below.
TEMP=$(getopt -o vdm: --long source:,destination:,skip_config,skip_schema,skip_data,skip_locales,skip_templates,allow_live,replace_src,force,verbose \
              -n 'javawrap' -- "$@")

if [ $? != 0 ] ; then echo -e "${RED}Error parsing ${LTRED}config.yml${RED}. Terminating.${NC}" >&2 ; exit 1 ; fi

# Note the quotes around '$TEMP': they are essential!
eval set -- "$TEMP"

# Read what source/destination the user wants to skip
while true; do
  case "$1" in
    --source ) source_env="$2"; shift 2 ;;
    --destination ) destination_env="$2"; shift 2 ;;
    --skip_config ) skip_config=true; skip_schema=true; skip_data=true; shift ;;
    --skip_schema ) skip_schema=true; shift ;;
    --skip_data ) skip_data=true; shift ;;
    --skip_locales ) skip_locales=true; shift ;;
    --skip_templates ) skip_templates=true; shift ;;
    --allow_live ) allow_live=true; shift ;;
    --replace_src ) replace_src=true; shift ;;
    --force ) force=true; shift ;;
    --verbose ) verbose=true; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done


# ===================================================================
# Parse YML Helper
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}


# Read config.yml
if [ -f "config.yml" ]; then
    if $verbose; then echo -e "Reading ${WHITE}config.yml${NC}..."; fi
    eval $(parse_yaml config.yml "conf_")
else
    echo -e "${RED}Error: ${LTRED}config.yml${RED} does not exist.${NC}"
    exit 1
fi


# ===================================================================
# Validate Source Inputs

var_source_store=conf_${source_env}_store
if [ -z "${!var_source_store}" ]
then
  echo -e "${RED}Error: '${LTRED}store${RED}' not defined in ${LTRED}config.yml${RED} for source '${LTRED}${source_env}${RED}'${NC}"
else
  source_store=${!var_source_store}
fi

var_source_password=conf_${source_env}_password
if [ -z "${!var_source_password}" ]
then
  echo -e "${RED}Error: '${LTRED}password${RED}' not defined in ${LTRED}config.yml${RED} for source '${LTRED}${source_env}${RED}'${NC}"
else
  source_password=${!var_source_password}
fi

var_source_theme_id=conf_${source_env}_theme_id
if [ -z "${!var_source_theme_id}" ]
then
  echo -e "${RED}Error: '${LTRED}theme_id${RED}' not defined in ${LTRED}config.yml${RED} for source '${LTRED}${source_env}${RED}'${NC}"
else
  source_theme_id=${!var_source_theme_id}
fi

var_source_directory=conf_${source_env}_directory
if [ -z "${!var_source_directory}" ]
then
  echo -e "${RED}Error: '${LTRED}directory${RED}' not defined in ${LTRED}config.yml${RED} for source '${LTRED}${source_env}${RED}'${NC}"
else
  source_directory=${!var_source_directory}
fi


# ===================================================================
# Validate Destination Inputs

var_destination_store=conf_${destination_env}_store
if [ -z "${!var_destination_store}" ]
then
  echo -e "${RED}Error: '${LTRED}store${RED}' not defined in ${LTRED}config.yml${RED} for destination '${LTRED}${destination_env}${RED}'${NC}"
else
  destination_store=${!var_destination_store}
fi

var_destination_password=conf_${destination_env}_password
if [ -z "${!var_destination_password}" ]
then
  echo -e "${RED}Error: '${LTRED}password${RED}' not defined in ${LTRED}config.yml${RED} for destination '${LTRED}${destination_env}${RED}'${NC}"
else
  destination_password=${!var_destination_password}
fi

var_destination_theme_id=conf_${destination_env}_theme_id
if [ -z "${!var_destination_theme_id}" ]
then
  echo -e "${RED}Error: '${LTRED}theme_id${RED}' not defined in ${LTRED}config.yml${RED} for destination '${LTRED}${destination_env}${RED}'${NC}"
else
  destination_theme_id=${!var_destination_theme_id}
fi

var_destination_directory=conf_${destination_env}_directory
if [ -z "${!var_destination_directory}" ]
then
  echo -e "${RED}Error: '${LTRED}directory${RED}' not defined in ${LTRED}config.yml${RED} for destination '${LTRED}${destination_env}${RED}'${NC}"
else
  destination_directory=${!var_destination_directory}
fi



# ===================================================================
# Abort on Validation Error
if [[ -z "${!var_source_store}" || -z "${!var_source_password}" || -z "${!var_source_theme_id}" || -z "${!var_source_directory}" || -z "${!var_destination_store}" || -z "${!var_destination_password}" || -z "${!var_destination_theme_id}" || -z "${!var_destination_directory}" ]]
then
  echo -e "${RED}Aborting due to validation errors.${NC}"
  exit 1
fi


# ===================================================================
# Set flags
allow_live_flag=""
if [[ $allow_live == true ]]
then
    allow_live_flag="--allow_live"
fi


# ===================================================================
# Build Source File List

source_file_list=""
if [[ $skip_schema != true ]]
then
    source_file_list="$source_file_list config/settings_schema.json"
fi

if [[ $skip_data != true ]]
then
    source_file_list="$source_file_list config/settings_data.json"
fi

if [[ $skip_locales != true ]]
then
    source_file_list="$source_file_list locales/*"
fi

if [[ $skip_templates != true ]]
then
    source_file_list="$source_file_list templates/*.json"
fi


# ===================================================================
# Review and Confirm Settings

# Review Settings
echo -e ""
echo -e "=============================================================="
echo -e "${WHITE}SETTINGS${NC}"
echo -e "=============================================================="
echo -e "Source:                ${WHITE}${source_env}${NC}"
echo -e "Source Store:          ${WHITE}${source_store}${NC}"
echo -e "Source Password:       ${WHITE}${source_password}${NC}"
echo -e "Source Theme ID:       ${WHITE}${source_theme_id}${NC}"
echo -e "Source Directory:      ${WHITE}${source_directory}${NC}"
echo -e "--------------------------------------------------------------"
echo -e "Destination:           ${WHITE}${destination_env}${NC}"
echo -e "Destination Store:     ${WHITE}${destination_store}${NC}"
echo -e "Destination Password:  ${WHITE}${destination_password}${NC}"
echo -e "Destination Theme ID:  ${WHITE}${destination_theme_id}${NC}"
echo -e "Destination Directory: ${WHITE}${destination_directory}${NC}"
echo -e "--------------------------------------------------------------"
echo -e "Skip config?           ${WHITE}${skip_config}${NC}"
echo -e "Skip schema?           ${WHITE}${skip_schema}${NC}"
echo -e "Skip data?             ${WHITE}${skip_data}${NC}"
echo -e "Skip locales?          ${WHITE}${skip_locales}${NC}"
echo -e "Skip templates?        ${WHITE}${skip_templates}${NC}"
echo -e "--------------------------------------------------------------"
echo -e "Replace /src?          ${WHITE}${replace_src}${NC}"
echo -e "Allow Live?            ${WHITE}${allow_live}${NC}"
echo -e "--------------------------------------------------------------"
echo -e "Files to sync:"
for source_pattern in $source_file_list
do
    echo -e "- ${WHITE}$source_pattern${NC}"
done
echo -e "=============================================================="
echo -e ""

# Confirm Settings (unless force mode)
if [[ $force != true ]]
then
    read -p "Are you ready to perform the update using these settings Y/[N]? " -n 1 confirm
    echo ""
    if [[ $confirm != "y" && $confirm != "Y" ]]
    then
        echo ""
    	  echo -e "${RED}Aborting.${NC}"
        exit 1
    fi
fi


# ===================================================================
# Pull from Source

echo ""
echo ""
echo -e "Getting source files from '${WHITE}${source_env}${NC}'..."
theme get --verbose --store="${source_store}" --password="${source_password}" --themeid="${source_theme_id}" --dir="${source_directory}" ${source_file_list}
echo ""

# ===================================================================
# If Syncing to localhost, also copy the files over to /src
if [[ $destination_env == "localhost" && $replace_src == true ]]
then
    echo -e "Replacing ${WHITE}/src${NC} with files sync'd from ${WHITE}${source_env}${NC}..."

    for source_pattern in $source_file_list
    do

        if $verbose; then echo -e "Crawling... '${WHITE}${source_directory}/$source_pattern${NC}'..."; fi
        if $verbose; then echo ""; fi

        shopt -s globstar
        source_pattern_full=${source_directory}/$source_pattern
        for new_file in $source_pattern_full
        do

            if $verbose; then echo -e "Searching ${WHITE}/src${NC} for '${WHITE}${new_file}${NC}'..."; fi;

            if [[ ${new_file##*/} ]]
            then
                old_file="$(find src/ -name ${new_file##*/} | tail -n1)"

                if [[ ${old_file} ]]
                then
                    echo -e "${GREEN}~${NC} Replacing '${WHITE}${old_file}${NC}'..."
                    cp ${new_file} ${old_file}
                    if $verbose; then echo ""; fi;
                else
                    if [[ $verbose == true ]]
                    then
                        echo -e "Unable to find '${WHITE}${new_file##*/}${NC}' [${WHITE}$new_file${NC}] in ${WHITE}/src${NC}; assuming it's new..."
                    fi
                    echo -e "${GREEN}+${NC} Adding '${WHITE}${new_file/$source_directory/src}${NC}'..."
                    cp ${new_file} ${new_file/$source_directory/src}
                    if $verbose; then echo ""; fi
                fi

            else
                echo -e "${RED}Error: Unable to identify new filename for '${LTRED}${new_file##*/}${RED}' [${LTRED}$new_file${RED}] (not copying to /src).${NC}"
                echo ""
            fi
        done

        if $verbose; then echo ""; fi

    done

    echo -e "${YELLOW}Note: files that were not found on ${WHITE}${source_env}${YELLOW} have not been deleted from ${WHITE}/src${YELLOW}, you must manually do this (if relevant)."
    # TODO: can we automate this? safely?
    echo ""
fi


# ===================================================================
# Build Destination File List

destination_file_list=""
if [[ $skip_schema != true ]]
then
    destination_file_list="$destination_file_list config/settings_schema.json"
fi

if [[ $skip_data != true ]]
then
    destination_file_list="$destination_file_list config/settings_data.json"
fi

if [[ $skip_locales != true ]]
then
    destination_file_list="$destination_file_list locales/"
fi

if [[ $skip_templates != true ]]
then
    shopt -s globstar
    cd ${source_directory}
    for file in templates/*.json
    do
        # echo "Destination File: ${file}";
        destination_file_list="$destination_file_list $file"
    done
    cd ..
fi


# ===================================================================
# Deploy to Destination

echo ""
echo ""
echo -e "Deploying to destination '${WHITE}${destination_env}${NC}'..."
if [[ $verbose ]]
then
    echo "Files to sync:"
    for destination_pattern in $destination_file_list
    do
        echo -e "- ${WHITE}$destination_pattern${NC}"
    done
    echo ""
fi
theme deploy --verbose --store="${destination_store}" --password="${destination_password}" --themeid="${destination_theme_id}" --dir="${destination_directory}" ${allow_live_flag} ${destination_file_list}
echo ""



# ===================================================================
# Done
echo -e "${GREEN}Sync complete.${NC}"
echo ""

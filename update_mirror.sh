#!/bin/bash

# Function to get the AlmaLinux version
get_almalinux_version() {
    cat /etc/os-release | grep -i "version" | awk -F= '{print $2}' | cut -d" " -f1 | cut -d"." -f1-2
}

# Function to select mirror URL based on the version
select_mirror_url() {
    local version=$1
    local mirror_base_url="https://mirror.limda.net/almalinux"

    if [[ "$version" == "8"* ]]; then
        echo "$mirror_base_url/8"
    elif [[ "$version" == "9"* ]]; then
        echo "$mirror_base_url/9"
    else
        echo "Unsupported AlmaLinux version"
        exit 1
    fi
}

# Function to update the mirror
update_mirror() {
    local mirror_url=$1
    echo "Updating the repository mirrors to $mirror_url..."

    # Backup current repo files
    sudo cp -r /etc/yum.repos.d /etc/yum.repos.d.bak

    # Update AlmaLinux repo configurations
    sudo sed -i "s|^baseurl=.*|baseurl=$mirror_url|g" /etc/yum.repos.d/*.repo

    # Clean and update metadata
    sudo dnf clean all
    sudo dnf update -y

    echo "Repository mirrors have been updated."
}

# Main script execution
almalinux_version=$(get_almalinux_version)
echo "Detected AlmaLinux version: $almalinux_version"

mirror_url=$(select_mirror_url "$almalinux_version")
update_mirror "$mirror_url"

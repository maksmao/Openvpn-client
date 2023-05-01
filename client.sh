#!/bin/bash
#

# -------------------
# VPN create new key
# -------------------

# General Env
Path_to_script=/etc/openvpn/easy-rsa/
Path_to_users=/etc/openvpn/easy-rsa/pki/index.txt
# Table
Path_to_client_table=/etc/openvpn/ccd/template/client-table
Path_to_admin_table=/etc/openvpn/ccd/template/admin-table
Path_to_node_table=/etc/openvpn/ccd/template/node-table
# Template
Path_to_client_template=/etc/openvpn/ccd/template/template-for-client
Path_to_admin_template=/etc/openvpn/ccd/template/template-for-admin
Path_to_node_template=/etc/openvpn/ccd/template/template-for-node

# Options 
PS3='Please enter your choice: '
options=("Create user with default expiration date" "Create user with custom expiration date" "List all clients" "Quit")
select opt in "${options[@]}"
do
        case $opt in
    # User with default expiration date
        "Create user with default expiration date")
            PS3='Enter type: '
            choose_options=("client" "admin" "node" "Back")
            select option in "${choose_options[@]}"
            do
                case $option in
            # Create Client
                    "client")
                        echo ""
                        echo "You chose client"
                        echo "-----------------------------------"
                        echo "Client with default expiration date"
                        echo "-----------------------------------"
                        echo "To create your openvpn Client you must type your Username"
                        echo "Type your Username:"
                    # Config Client with default expiration date 
                        read  Username
                        USERNAME_EXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "CN=$Username" )
                        if [[ $USERNAME_EXISTS == '1' ]]; then
                            echo  ""
                            echo "The specified client CN was already found in easy-rsa, please choose another name."
                        exit 1
                        else 
                    # Env for client with default expiration date
                        Path_to_client=/etc/openvpn/client/$Username.opvn
                        Path_to_cert=/etc/openvpn/easy-rsa/pki/issued/$Username.crt
                        Path_to_key=/etc/openvpn/easy-rsa/pki/private/$Username.key
                    # Script Execution
                        cd $Path_to_script
                        ./easyrsa gen-req "$Username" nopass
                        ./easyrsa sign-req client "$Username"
                    # Group  Certificate and Key into /etc/openvpn/client/$Username.opvn.
                        echo ""
                        echo "----------"
                        echo "Group "$Username" .crt and .key into "$Path_to_client""
                        cat $Path_to_client_template $Path_to_cert $Path_to_key > $Path_to_client
                    # Add $Username with IP to /etc/openvpn/ccd/client-table.
                        echo "----------"
                        echo "Add "$Username" into "$Path_to_client_table""
                        Command=$(cat $Path_to_client_table | tail -1 | awk '{print$2}' | awk -F "." '{print $3+1}')
                        echo ""$Username" 10.50."$Command".0" >> $Path_to_client_table
                    # Touch file /etc/openvpn/ccd/"$Username" with ifconf, push route, iroute.
                        echo "----------"
                        echo "Touch file /etc/openvpn/ccd/"$Username""
                        touch   /etc/openvpn/ccd/$Username
                        Command_two=$(cat $Path_to_client_table | tail -1 | awk '{print$2}')
                        echo "ifconfig-push 10.8.134."$Command" 255.255.255.0" >> /etc/openvpn/ccd/$Username
                        echo 'push "route 10.0.1.0 255.255.255.0 10.8.134.1"' >>  /etc/openvpn/ccd/$Username
                        echo "iroute "$Command_two" 255.255.255.0" >>  /etc/openvpn/ccd/$Username
                    # LAST STEP 
                        echo 'push "route '$Command_two' 255.255.255.0 10.8.134.'$Command'"' >> $Path_to_node_template
                        for file in /etc/openvpn/ccd/node*
                            do
                                echo 'push "route '$Command_two' 255.255.255.0 10.8.134.'$Command'"' >> "$file"
                            done
                        exit 1
                        fi
                        ;;
            # Create Admin
                    "admin")
                        echo ""
                        echo "You chose admin"
                        echo "-----------------------------------"
                        echo "Admin with default expiration date"
                        echo "-----------------------------------"
                        echo "To create your openvpn Admin you must type your Username"
                        echo "Type your Username:"
                    # Config Admin with default expiration date 
                        read  Username
                        USERNAME_EXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "CN=$Username" )
                        if [[ $USERNAME_EXISTS == '1' ]]; then
                            echo  ""
                            echo "The specified admin CN was already found in easy-rsa, please choose another name."
                        exit 1
                        else
                    # Env for client with default expiration date
                        Path_to_admin=/etc/openvpn/client/$Username.opvn
                        Path_to_cert=/etc/openvpn/easy-rsa/pki/issued/$Username.crt
                        Path_to_key=/etc/openvpn/easy-rsa/pki/private/$Username.key
                    # Script Execution
                        cd $Path_to_script
                        ./easyrsa gen-req "$Username" nopass
                        ./easyrsa sign-req client "$Username"
                    # Group  Certificate and Key into /etc/openvpn/client/$Username.opvn.
                        echo ""
                        echo "----------"
                        echo "Group "$Username" .crt and .key into "$Path_to_admin""
                        cat $Path_to_cert $Path_to_key > $Path_to_admin
                    # Add $Username with IP to /etc/openvpn/ccd/admin-table.
                        echo "----------"
                        echo "Add "$Username" into "$Path_to_admin_table""
                        Command=$(cat $Path_to_admin_table | tail -1 | awk '{print$2}' | awk -F "." '{print $4+1}')
                        echo "ifconfig-push 10.8.134."$Command" 255.255.255.0" >> $Path_to_admin_table
                    # Touch file /etc/openvpn/ccd/"$Username" with ifconf and push route.
                        echo "----------"
                        echo "Touch file /etc/openvpn/ccd/"$Username""
                        touch   /etc/openvpn/ccd/$Username
                        Command_two=$(cat $Path_to_admin_table | tail -1)
                        echo ""$Command_two"" >> /etc/openvpn/ccd/$Username
                        cat $Path_to_admin_template >> /etc/openvpn/ccd/$Username
                        exit 1
                        fi
                        ;;
            # Create Node
                    "node")
                    # Config Node with default expiration date 
                        echo ""
                        echo "You chose node"
                        echo "-----------------------------------"
                        echo "Node with default expiration date"
                        echo "-----------------------------------"
                        echo "To create your openvpn Node you must type your Username"
                        echo "Type your Username:"
                        read  Username
                        USERNAME_EXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "CN=$Username" )
                        if [[ $USERNAME_EXISTS == '1' ]]; then
                            echo  ""
                            echo "The specified admin CN was already found in easy-rsa, please choose another name."
                        exit 1
                        else
                        Path_to_node=/etc/openvpn/client/$Username.opvn
                        Path_to_cert=/etc/openvpn/easy-rsa/pki/issued/$Username.crt
                        Path_to_key=/etc/openvpn/easy-rsa/pki/private/$Username.key
                    # Script Execution
                        cd $Path_to_script
                        ./easyrsa gen-req "$Username" nopass
                        ./easyrsa sign-req client "$Username"
                    # Group  Certificate and Key into /etc/openvpn/client/$Username.opvn.
                        echo ""
                        echo "----------"
                        echo "Group "$Username" .crt and .key into "$Path_to_node""
                        cat $Path_to_cert $Path_to_key > $Path_to_node
                    # Add $Username with IP to /etc/openvpn/ccd/admin-table.
                        echo "----------"
                        echo "Add "$Username" into "$Path_to_node_table""
                        Command=$(cat $Path_to_node_table | tail -1 | awk '{print$2}' | awk -F "." '{print $4+1}')
                        echo "ifconfig-push 10.8.134."$Command" 255.255.255.0" >> $Path_to_node_table
                    # Touch file /etc/openvpn/ccd/"$Username" with ifconf and push route.
                        echo "----------"
                        echo "Touch file /etc/openvpn/ccd/"$Username""
                        touch   /etc/openvpn/ccd/$Username
                        Command_two=$(cat $Path_to_node_table | tail -1)
                        echo ""$Command_two"" >> /etc/openvpn/ccd/$Username 
                        cat $Path_to_node_template >> /etc/openvpn/ccd/$Username
                        exit 1
                        fi
                        ;;
            # Create Back
                    "Back")
                        echo  "1) Create client with default expiration date"
                        echo  "2) Create client with custom expiration date"     
                        echo  "3) List all clients"
                        echo  "4) Quit"
                        break
                        ./client.sh
                        ;;
                    *) echo "Invalid option $REPLY" 
                        ;;
                esac
            done
            ;;
    # Create user with custom expiration date
        "Create user with custom expiration date")
            PS3='Enter type: '
            choose_options=("client" "admin" "node" "Back")
            select option in "${choose_options[@]}"
            do
                case $option in
                    "client")
                        echo ""
                        echo "You chose client"
                        echo "-----------------------------------"
                        echo "Client with default expiration date"
                        echo "-----------------------------------"
                        echo "To create your openvpn Client you must type your Username"
                        echo "Type your Username:"
                    # Config Client with default expiration date 
                        read  Username
                        echo "Type custom expitation date of certificate: "
                        read Expiration_Date
                        USERNAME_EXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "CN=$Username" )
                        if [[ $USERNAME_EXISTS == '1' ]]; then
                            echo  ""
                            echo "The specified client CN was already found in easy-rsa, please choose another name."
                        exit 1
                        else 
                    # Env for client with default expiration date
                        Path_to_client=/etc/openvpn/client/$Username.opvn
                        Path_to_cert=/etc/openvpn/easy-rsa/pki/issued/$Username.crt
                        Path_to_key=/etc/openvpn/easy-rsa/pki/private/$Username.key
                        export EASYRSA_CERT_EXPIRE=$Expiration_Date
                    # Script Execution
                        cd $Path_to_script
                        ./easyrsa gen-req "$Username" nopass
                        ./easyrsa sign-req client "$Username"
                    # Group  Certificate and Key into /etc/openvpn/client/$Username.opvn.
                        echo ""
                        echo "----------"
                        echo "Group "$Username" .crt and .key into "$Path_to_client""
                        cat $Path_to_client_template $Path_to_cert $Path_to_key > $Path_to_client
                    # Add $Username with IP to /etc/openvpn/ccd/client-table.
                        echo "----------"
                        echo "Add "$Username" into "$Path_to_client_table""
                        Command=$(cat $Path_to_client_table | tail -1 | awk '{print$2}' | awk -F "." '{print $3+1}')
                        echo ""$Username" 10.50."$Command".0" >> $Path_to_client_table
                    # Touch file /etc/openvpn/ccd/"$Username" with ifconf, push route, iroute.
                        echo "----------"
                        echo "Touch file /etc/openvpn/ccd/"$Username""
                        touch   /etc/openvpn/ccd/$Username
                        Command_two=$(cat $Path_to_client_table | tail -1 | awk '{print$2}')
                        echo "ifconfig-push 10.8.134."$Command" 255.255.255.0" >> /etc/openvpn/ccd/$Username
                        echo "push 'route 10.0.1.0 255.255.255.0 10.8.134.1'" >>  /etc/openvpn/ccd/$Username
                        echo "iroute "$Command_two" 255.255.255.0" >>  /etc/openvpn/ccd/$Username
                    # LAST STEP 
                        echo 'push "route '$Command_two' 255.255.255.0 10.8.134.'$Command'"' >> $Path_to_node_template
                        for file in /etc/openvpn/ccd/node*
                            do
                                echo 'push "route '$Command_two' 255.255.255.0 10.8.134.'$Command'"' >> "$file"
                            done
                        exit 1
                        fi
                        ;;
            # Create Admin
                    "admin")
                        echo ""
                        echo "You chose admin"
                        echo "-----------------------------------"
                        echo "Admin with default expiration date"
                        echo "-----------------------------------"
                        echo "To create your openvpn Admin you must type your Username"
                        echo "Type your Username:"
                    # Config Admin with default expiration date 
                        read  Username
                        echo "Type custom expitation date of certificate: "
                        read Expiration_Date
                        USERNAME_EXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "CN=$Username" )
                        if [[ $USERNAME_EXISTS == '1' ]]; then
                            echo  ""
                            echo "The specified admin CN was already found in easy-rsa, please choose another name."
                        exit 1
                        else
                    # Env for client with default expiration date
                        Path_to_admin=/etc/openvpn/client/$Username.opvn
                        Path_to_cert=/etc/openvpn/easy-rsa/pki/issued/$Username.crt
                        Path_to_key=/etc/openvpn/easy-rsa/pki/private/$Username.key
                        export EASYRSA_CERT_EXPIRE=$Expiration_Date
                    # Script Execution
                        cd $Path_to_script
                        ./easyrsa gen-req "$Username" nopass
                        ./easyrsa sign-req client "$Username"
                    # Group  Certificate and Key into /etc/openvpn/client/$Username.opvn.
                        echo ""
                        echo "----------"
                        echo "Group "$Username" .crt and .key into "$Path_to_admin""
                        cat $Path_to_cert $Path_to_key > $Path_to_admin
                    # Add $Username with IP to /etc/openvpn/ccd/admin-table.
                        echo "----------"
                        echo "Add "$Username" into "$Path_to_admin_table""
                        Command=$(cat $Path_to_admin_table | tail -1 | awk '{print$2}' | awk -F "." '{print $4+1}')
                        echo "ifconfig-push 10.8.134."$Command" 255.255.255.0" >> $Path_to_admin_table
                    # Touch file /etc/openvpn/ccd/"$Username" with ifconf and push route.
                        echo "----------"
                        echo "Touch file /etc/openvpn/ccd/"$Username""
                        touch   /etc/openvpn/ccd/$Username
                        Command_two=$(cat $Path_to_admin_table | tail -1)
                        echo ""$Command_two"" >> /etc/openvpn/ccd/$Username
                        cat $Path_to_admin_template >> /etc/openvpn/ccd/$Username
                        exit 1
                        fi
                        ;;
            # Create node
                    "node")
                    # Config Node with default expiration date 
                        echo ""
                        echo "You chose node"
                        echo "-----------------------------------"
                        echo "Node with default expiration date"
                        echo "-----------------------------------"
                        echo "To create your openvpn Node you must type your Username"
                        echo "Type your Username:"
                        read  Username
                        echo "Type custom expitation date of certificate: "
                        read Expiration_Date
                        USERNAME_EXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "CN=$Username" )
                        if [[ $USERNAME_EXISTS == '1' ]]; then
                            echo  ""
                            echo "The specified admin CN was already found in easy-rsa, please choose another name."
                        exit 1
                        else
                        Path_to_node=/etc/openvpn/client/$Username.opvn
                        Path_to_cert=/etc/openvpn/easy-rsa/pki/issued/$Username.crt
                        Path_to_key=/etc/openvpn/easy-rsa/pki/private/$Username.key
                        export EASYRSA_CERT_EXPIRE=$Expiration_Date
                    # Script Execution
                        cd $Path_to_script
                        ./easyrsa gen-req "$Username" nopass
                        ./easyrsa sign-req client "$Username"
                    # Group  Certificate and Key into /etc/openvpn/client/$Username.opvn.
                        echo ""
                        echo "----------"
                        echo "Group "$Username" .crt and .key into "$Path_to_node""
                        cat $Path_to_cert $Path_to_key > $Path_to_node
                    # Add $Username with IP to /etc/openvpn/ccd/admin-table.
                        echo "----------"
                        echo "Add "$Username" into "$Path_to_node_table""
                        Command=$(cat $Path_to_node_table | tail -1 | awk '{print$2}' | awk -F "." '{print $4+1}')
                        echo "ifconfig-push 10.8.134."$Command" 255.255.255.0" >> $Path_to_node_table
                    # Touch file /etc/openvpn/ccd/"$Username" with ifconf and push route.
                        echo "----------"
                        echo "Touch file /etc/openvpn/ccd/"$Username""
                        touch   /etc/openvpn/ccd/$Username
                        Command_two=$(cat $Path_to_node_table | tail -1)
                        echo ""$Command_two"" >> /etc/openvpn/ccd/$Username 
                        cat $Path_to_node_template >> /etc/openvpn/ccd/$Username 
                        exit 1
                        fi
                        ;;
            # Back   
                    "Back")
                        echo  "1) Create client with default expiration date"
                        echo  "2) Create client with custom expiration date"     
                        echo  "3) List all clients"
                        echo  "4) Quit"
                        break
                        ./client.sh
                        ;;
                    *) echo "Invalid option $REPLY" 
                        ;;
                esac
            done
            ;;
        "List all clients")
            cat $Path_to_users
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY"
           ;;
        esac
done
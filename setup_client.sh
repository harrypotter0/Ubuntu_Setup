#!/bin/bash
ask() {
    while true; do
        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        read -p "$1 [$prompt] " REPLY
 
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi
 
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac 
    done
}

#
# GENERATE NEW SSH KEY
#

if [ ! -f ~/.ssh/id_rsa.pub ]; then
	ssh-keygen;
fi

echo "--------------- Here is your ssh public key";
cat ~/.ssh/id_rsa.pub || echo;

if ask "--------------- Have you copied the key? Can we proceed?" y; then
    echo "Forward...";
else
    exit 0;
fi

#
# REPOSITORIES
#

echo "--------------- Adding new repositories";
# sublime text 3
if [ $(sudo apt-cache policy | grep -c "sublime-text-3") -eq 0 ];
then
	sudo add-apt-repository ppa:webupd8team/sublime-text-3;
else
	echo "--------------- Sublime Text 3 repository already installed";
fi
# brackets
if [ $(sudo apt-cache policy | grep -c "brackets") -eq 0 ];
then
	sudo add-apt-repository ppa:webupd8team/brackets;
else
	echo "--------------- Brackets repository already installed";
fi
# chrome
if [ $(sudo apt-cache policy | grep -c "chrome") -eq 0 ];
then
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - ;
	sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list';
else
	echo "--------------- Chrome repository already installed";
fi
#skype
if [ $(sudo apt-cache policy | grep -c "skype") -eq 0 ];
then
	sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner";
else
	echo "--------------- Skype repository already installed";
fi
#java
if [ $(sudo apt-cache policy | grep -c "java") -eq 0 ];
then
	sudo add-apt-repository -y ppa:webupd8team/java
else
	echo "--------------- Java repository already installed";
fi

#
# UPDATE / UPGRADE
#

echo "--------------- Update + Upgrade";

sudo apt-get update;
sudo apt-get -y upgrade;
# sudo apt-get dist-upgrade

#
#  INSTALL
#
echo "--------------- Installing Tools";

apt_get_packages=("google-chrome-stable" "brackets" "sublime-text-installer" "git" "curl" "git-core" "gitk" "gitg" "git-gui" "nodejs-legacy" "npm" "mysql-server" "php5-mysqlnd" "php5-fpm" "php5-cli" "php5-mcrypt" "php5-curl" "php5-json" "php5-gd" "php5-dev" "php-pear" "php5-xdebug" "nginx" "ruby-full" "phantomjs" "filezilla" "virtualbox" "virtualbox-dkms" "vagrant" "skype" "docker.io" "python-pip" "meld" "inotify-tools" "openjdk-8-jre" "oracle-java8-installer" "whois" "mytop" "jmeter" "awscli" "ec2-api-tools");

for i in "${!apt_get_packages[@]}"; do
	if [ $(dpkg-query -W -f='${Status}' "${apt_get_packages[$i]}" 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		echo "--------------- Installing ${apt_get_packages[$i]}";
		if [ $(echo ${apt_get_packages[$i]} | grep -c "sublime-text-installer") -eq 1 ]
		then
			sudo apt-get install -y sublime-text;
		else
			sudo apt-get install -y ${apt_get_packages[$i]};
		fi
	else
		echo "--------------- '${apt_get_packages[$i]}' already installed";
	fi
done

sudo php5enmod mcrypt;
sudo php5enmod xdebug;

npm_packages=("gulp" "bower" "mup" "browserify");

for i in "${!npm_packages[@]}"; do

	if [ $(npm list -g "${npm_packages[$i]}" 2>/dev/null | grep -c "${npm_packages[$i]}") -eq 0 ];
	then
		echo "--------------- Installing ${npm_packages[$i]}";
		sudo npm install -g ${npm_packages[$i]};
	else
		echo "--------------- '${npm_packages[$i]}' already installed";
	fi
done

sudo chown -R $LOGNAME:$LOGNAME ~/.npm;

# composer
if [ ! -f /usr/local/bin/composer ]; then
	echo "--------------- Installing Composer";
	curl -sS https://getcomposer.org/installer | php;
	sudo mv composer.phar /usr/local/bin/composer;
else
	echo "--------------- Updating Composer";
	sudo composer self-update;
fi

# meteor js
if [ ! -d ~/.meteor ]; then
	echo "--------------- Installing Meteor";
	curl https://install.meteor.com/ | sh;
fi

#
# ADD ALIASES TO BASH
#
if [ $(cat ~/.bashrc | grep -c "mybash") -eq 0 ];
then
	
	# working on
	#Install Elastic Beanstalk
	#if [ $($LOGNAME | grep -c "jonathan") -eq 1 ];
	#then
		# Download From https://s3.amazonaws.com/elasticbeanstalk/cli/AWS-ElasticBeanstalk-CLI-2.6.4.zip
		#export PATH=$PATH:/usr/share/aws/eb/linux/python2.7/
	#fi

echo '

alias reload="sudo service nginx reload"
alias restart="sudo service nginx restart"
alias restartphp="sudo service php5-fpm restart"
alias restartsql="sudo service mysql restart"

alias hosts="sudo subl /etc/hosts"
alias phpini="sudo subl /etc/php5/fpm/php.ini"
alias mybash="subl ~/.bashrc"
alias vhosts="sudo subl /etc/nginx/sites-available;"

alias www="cd /var/www; ls -li"
alias html="cd /var/www/html; ls -li"
alias dev="cd /var/www/dev; ls -li"
alias logs="cd /var/log/nginx; ls -li"

alias dir="ls -la"
alias b="cd .."
alias ..="cd .."
alias ...="cd ../.."

alias dump="composer dump-autoload;"
alias migrate="php artisan migrate;"
alias refresh="php artisan migrate:refresh --seed";
alias seed="php artisan db:seed";

alias push="git push origin develop;";

alias run="codecept run -d;";

' >> ~/.bashrc;
	exec bash;
fi


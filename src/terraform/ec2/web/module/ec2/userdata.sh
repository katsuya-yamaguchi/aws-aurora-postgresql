#!/bin/bash
LOG=/var/log/user-data.log

touch $LOG
chmod 777 $LOG

echo "=============================" >> $LOG
echo "= START userdata script." >> $LOG
echo "=============================" >> $LOG

echo "# START assets:precompile" >> $LOG
su - app-user -c 'cd /home/app-user/www/app && bundle exec rake assets:precompile' >> $LOG
echo "# END   assets:precompile" >> $LOG

echo "# START puma" >> $LOG
cd /home/app-user/www/app
. ~/.bash_profile
/home/app-user/.rbenv/shims/bundle exec puma -t 5:5 -C config/puma.rb -e production -p 80 -d >> $LOG
echo "# END   puma" >> $LOG

echo "=============================" >> $LOG
echo "= END userdata script." >> $LOG
echo "=============================" >> $LOG

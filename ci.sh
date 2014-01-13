set -x

cd mapi-kata
bash setup.sh
cd -

bundle
bundle exec rackup -p 12346 -D

cd mapi-kata
bash run.sh
RETVAL=$?
cd -

kill `cat rack.pid`

exit $RETVAL

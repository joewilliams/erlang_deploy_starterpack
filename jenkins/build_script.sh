## Copyright 2012, Joe Williams <joe@joetify.com>
##
## Permission is hereby granted, free of charge, to any person
## obtaining a copy of this software and associated documentation
## files (the "Software"), to deal in the Software without
## restriction, including without limitation the rights to use,
## copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following
## conditions:
##
## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
## HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## OTHER DEALINGS IN THE SOFTWARE.


# this is a basic build script intended for use with jenkins

#
# set erlang version
#

export PATH=/opt/erlang/R14B04/bin:$PATH

#
# make sure things are clean, built and tested
#

./rebar clean
./rebar get-deps
./rebar compile
./rebar eunit

#
# build the release
#

./rebar generate
cd rel
tar zcf "$JOB_NAME"_"$BUILD_NUMBER"_release.tar.gz $JOB_NAME
cd ..

#
# set the build number you are upgrading from
#

UPGRADE_FROM_BUILD=1

#
# build upgrade
#

./rebar generate-appups previous_release=../../../jobs/$JOB_NAME/builds/$UPGRADE_FROM_BUILD/archive/rel/$JOB_NAME
./rebar generate-upgrade previous_release=../../../jobs/$JOB_NAME/builds/$UPGRADE_FROM_BUILD/archive/rel/$JOB_NAME
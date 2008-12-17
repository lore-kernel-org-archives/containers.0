From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] keys: play nicely with user namespaces
Date: Wed, 17 Dec 2008 17:55:36 -0600
Message-ID: <20081217235536.GA932@us.ibm.com>
References: <20081212141707.GB9571@us.ibm.com>
	<20081211232323.GA8343@us.ibm.com> <3507.1229086294@redhat.com>
	<25987.1229097458@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <25987.1229097458-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > Do you have an automated testsuite for the keyrings?  I just played
> > around with keyctl to test, since there was nothing in ltp.
> 
> Yes.
> 
> 	http://people.redhat.com/~dhowells/keys/keyutils/keyutils-tests.tar.bz2
> 
> which may need:
> 
> 	http://people.redhat.com/~dhowells/keys/keyutils/rhts_environment.sh
> 
> The tests are designed to run under RH's automated test environment.  All my
> tests are shell scripts that wrap the keyctl program.

With a plain security-next tree, I get the following output (as well as
with a patched one).  Expected?

root@sergelap:/mnt/userns-test/keyutils-tests# make runtest
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/add/noargs'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/7732
Joined session keyring: 1022953145
+++ ADD NO ARGS
+++ ADD ONE ARG
+++ ADD TWO ARGS
+++ ADD THREE ARGS
+++ ADD FIVE ARGS
Reporting test DevelopersOwnTest as PASS
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/add/noargs'
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/add/bad-args'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/7764
Joined session keyring: 730770469
+++ CHECK EMPTY KEY TYPE
+++ CHECK UNSUPPORTED KEY TYPE
+++ CHECK INVALID KEY TYPE
+++ CHECK MAXLEN KEY TYPE
+++ CHECK OVERLONG KEY TYPE
+++ CHECK ADD KEYRING WITH PAYLOAD
+++ CHECK MAXLEN DESC
+++ CHECK OVERLONG DESC
+++ CHECK BAD KEY ID
Reporting test DevelopersOwnTest as PASS
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/add/bad-args'
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/add/useradd'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/7818
Joined session keyring: 788468022
+++ ADD USER KEY
+++ PRINT PAYLOAD
+++ UPDATE USER KEY
+++ PRINT UPDATED PAYLOAD
+++ ADD KEY TO NON-KEYRING
+++ UNLINK KEY
Session Keyring
       -3 --alswrv      0     0  keyring: RHTS/keyctl/7818
Reporting test DevelopersOwnTest as PASS
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/add/useradd'
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/pupdate/noargs'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/7860
Joined session keyring: 703700630
+++ PUPDATE NO ARGS
+++ PUPDATE TWO ARGS
Reporting test DevelopersOwnTest as PASS
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/pupdate/noargs'
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/pupdate/userupdate'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/7889
Joined session keyring: 538541192
+++ ADD USER KEY
+++ PRINT PAYLOAD
+++ PUPDATE USER KEY
+++ PRINT UPDATED PAYLOAD
+++ UNLINK KEY
Reporting test DevelopersOwnTest as PASS
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/pupdate/userupdate'
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/pupdate/bad-args'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/7926
Joined session keyring: 74932378
+++ CHECK UPDATE SESSION KEYRING
+++ CHECK UPDATE INVALID KEY
+++ ADD USER KEY
+++ UNLINK KEY
+++ UPDATE UNLINKED KEY
Reporting test DevelopersOwnTest as PASS
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/pupdate/bad-args'
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/instantiating/noargs'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/7971
Joined session keyring: 346603144
+++ NO ARGS
+++ ONE ARG
+++ TWO ARGS
+++ THREE ARGS
+++ FOUR ARGS
Reporting test DevelopersOwnTest as PASS
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/instantiating/noargs'
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/instantiating/bad-args'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/8009
Joined session keyring: 154433922
+++ CHECK BAD KEY ID
+++ CREATE KEY
+++ CHECK ALREADY INSTANTIATED KEY
+++ CHECK NEGATE TIMEOUT
+++ UNLINK KEY
+++ CHECK NON-EXISTENT KEY ID
Reporting test DevelopersOwnTest as PASS
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/instantiating/bad-args'
make[1]: Entering directory `/mnt/userns-test/keyutils-tests/keyctl/permitting/valid'
sh ./runtest.sh
Running with session keyring RHTS/keyctl/8073
Joined session keyring: 97798558
+++ ADD KEYRING
+++ ADD KEY
+++ CHOWN
FAILED
+++ CHGRP
+++ ITERATE PERMISSIONS
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
FAILED
+++ VIEW GROUP PERMISSIONS
FAILED
+++ VIEW OTHER PERMISSIONS
FAILED
+++ REMOVE SETATTR
FAILED
FAILED
FAILED
+++ REINSTATE SETATTR
+++ UNLINK KEYRING
Reporting test DevelopersOwnTest as FAIL
/usr/bin/rhts_environment.sh: line 24: rhts_db_submit_result: command not found
make[1]: *** [runtest] Error 1
make[1]: Leaving directory `/mnt/userns-test/keyutils-tests/keyctl/permitting/valid'

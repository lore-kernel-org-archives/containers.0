From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH][lxc]: Add --with-usercr configure option
Date: Thu, 25 Mar 2010 10:20:48 -0700
Message-ID: <20100325172048.GB5847@us.ibm.com>
References: <20100325010524.GA7385@us.ibm.com>
	<1269505143.2914.87.camel@pagloppaglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1269505143.2914.87.camel@pagloppaglop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michel Normand <normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dlezcano-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Michel Normand [normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
| Suka, =

| I am adding my own comments, even if mail addressed to Daniel.

I did mean to CC you since you had a comment on this earlier. But even
otherwise, comments always welcome :-)

| =

| Le mercredi 24 mars 2010 =E0 18:05 -0700, Sukadev Bhattiprolu a =E9crit :
| > Pls let me know if this will work. Will address your other comments
| > and repost entire patchset.
| > =

| > ---
| > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > Date: Wed, 24 Mar 2010 17:26:44 -0700
| > Subject: [PATCH 1/1] Add --with-usercr configure option
| > =

| > Add a configure option, --with-usercr=3Ddir which would allow linking
| > with external (i.e USERCR) implementation  of checkpoint/restart.
| > =

| > For now, USERCR "publishes" a app-checkpoint.h, checkpoint.o and
| > restart.o files which implement the functions app_checkpoint() and
| > app_restart().
| > =

| > Usage:
| > 	$ ./autogen.sh
| > =

| > 	$ ./configure --help |grep usercr
| > 	--with-usercr=3Ddir     use the Checkpoint/Restart implementation in '=
dir'
| > =

| > 	$ ls /home/guest/user-cr/
| > 	app-checkpoint.h    checkpoint.o    restart.o
| > =

| > 	$ ./configure --with-usercr=3D/home/guest/user-cr
| > =

| > TODO:
| > 	If names of interfaces in USERCR change, we may want to rename
| > 	the config option too ?
| =

| not sure to understand, but the --with-usercr to stay lowercase.

I was just not sure if the name 'with-usercr' made sense for long term :-)
Like Daniel suggested, I will go with --with-cr for now. Maybe --with-libcr
would make more sense in the long run.

| =

| > =

| > 	Can we remove the src/lxc/{checkpoint.o,restart.o} files from
| > 	liblxc.so and lxc-checkpoint/lxc-restart directly with them ?
| > 	That way, the USERCR interfaces/object files don't end up in
| > 	liblxc.so.
| > =

| > 	USERCR_CFLAGS are only needed for src/lxc/{checkpoint.c,restart.c}
| > 	but not sure if there is an easy way to define autoconf CFLAGS
| > 	just for those two files.
| =

| exemple should work (I did not tried)
| lxc_checkpoint_SOURCES =3D lxc_checkpoint.c
| lxc_checkpoint_CFLAGS =3D -I$(top_srcdir)/src $(USERCR_CFLAGS)

Hmm, I meant that the additional CFLAGS are needed for src/lxc/checkpoint.c
 not src/lxc/lxc_checkpoint.c.

Since this checkpoint.c goes into liblxc.so, I tried:

checkpoint_CFLAGS =3D $(liblxc_so_CFLAGS) $(USERCR_CFLAGS)

but that did not work. Maybe I am missing something still.

| =

| > =

| > Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > ---
| >  configure.ac        |   19 +++++++++++++++++++
| >  src/lxc/Makefile.am |   10 +++++++++-
| >  2 files changed, 28 insertions(+), 1 deletions(-)
| > =

| > diff --git a/configure.ac b/configure.ac
| > index f82e7df..dd46e4d 100644
| > --- a/configure.ac
| > +++ b/configure.ac
| > @@ -12,6 +12,25 @@ AM_PROG_CC_C_O
| >  AC_GNU_SOURCE
| >  AC_CHECK_PROG(SETCAP, setcap, yes, no, $PATH$PATH_SEPARATOR/sbin)
| >  =

| > +AC_ARG_WITH(usercr, [AS_HELP_STRING([--with-usercr=3Ddir], \
| > +           [use the Checkpoint/Restart implementation in 'dir'])], [],=
 \
| > +	   [with_usercr=3Dno])
| > +
| > +if test "x$with_usercr" !=3D "xno"; then
| > +       AS_AC_EXPAND(USERCR_OBJS, "${with_usercr}/checkpoint.o ${with_u=
sercr}/restart.o")
| > +       AS_AC_EXPAND(USERCR_CFLAGS, "-DUSERCR -I${with_usercr}")
| > +
| > +       AC_CHECK_FILE([$with_usercr/app-checkpoint.h], [], \
| > +               AC_MSG_ERROR([--with-usercr specified directory $with_u=
sercr but $with_usercr/app-checkpoint.h was not found]))
| > +
| > +       AC_CHECK_FILE([${with_usercr}/checkpoint.o], [], \
| > +               AC_MSG_ERROR([--with-usercr specified directory $with_u=
sercr but ${with_usercr}/checkpoint.o was not found]))
| > +
| > +       AC_CHECK_FILE([${with_usercr}/restart.o], [], \
| > +               AC_MSG_ERROR([--with-usercr specified directory $with_u=
sercr but ${with_usercr}/restart.o was not found]))
| =

| I do not think the three above AC_CHECK_FILE are a good thing to be done
| as would need to have the user-cr to be already compiled
| at time of configure of lxc.

At this time, we do expect that the external C/R implementation to be
compiled - it is not something that is built in LXC right ?

One reason I was trying to do the check is if there is a typo in the
path specified by the user, the error would not be reported until the
make and it could be confusing error message.

How about I leave the check for 'app-checkpoint.h' and later when the
library is implemented, we could check for the existence of the library.

| I think this is better to detect such problem at time of make.
| =


Sukadev

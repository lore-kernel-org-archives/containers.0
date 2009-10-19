From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH user-cr] return, don't exist, at coord error
Date: Sun, 18 Oct 2009 22:50:33 -0500
Message-ID: <20091019035033.GA23390@us.ibm.com>
References: <20091019022942.GA21306@us.ibm.com> <4ADBD593.9070006@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ADBD593.9070006-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hmm, well...  I dont' know what's going on with my userspace,
Now it's not working for me even with this patch.

As root I do:

	setcap cap_sys_admin+pe /bin/restart
	ckpt > /tmp/out

then as a non-rootuid I do
	cat /tmp/out | /bin/retart -vd
	echo $?

giving me:
[hallyn@linuz11 ~]$ /bin/restart -vd  < /tmp/out
<4028>number of tasks: 1
<4028>total tasks (including ghosts): 2
<4028>pid 4177: propagate session 4285
<4028>pid 4177: creator set to 4285
<4028>pid 4177: set session
<4028>pid 4177: moving up to 4285
<4028>[0] pid 4285 ppid 4177 sid 0 creator 0       
<4028>[1] pid 4177 ppid 4285 sid 4285 creator 4285   S G 
<4028>found pgid/sid 0, need pidns
<4028>new pidns without init
<4028>forking coordinator in new pidns
<1>forking child vpid 4285 flags 0x1
<1>forked child vpid 2 (asked 4285)
<2>root task pid 2
<2>pid 4285: pid 2 sid 0 parent 1
<2>pid 4285: fork child 4177 with session
<2>forking child vpid 4177 flags 0x12
<3>pid 4177: pid 3 sid 0 parent 2
<4029>c/r swap old 4177 new 3
<3>about to call sys_restart(), flags 0x4
<2>forked child vpid 3 (asked 4177)
<4029>c/r swap old 4285 new 2
<4029>c/r read input 16384
<4029>c/r read input 16384
<4029>c/r read input 16384
restart failed: Operation not permitted
Failed
<1>restart failed ?
<4029>c/r read input 16384
<4029>c/r read input 14862
<2>about to call sys_restart(), flags 0
<4028>SIGCHLD: already collected
<4028>task exited with status 255
[hallyn@linuz11 ~]$ echo $?
0

And when I previously added a debug statement at
the end of main() printin gout the return value, it would
say 'returning 0' even though 'restart failed ?' in the
restart -vd output inicates that ret < 0.

Note that if you don't set cap_sys_admin+pe on
/bin/restart, then restart does return 255 (-1).

I'm done for the day - will have to look at it more
tomorrow.

-serge

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> What was the command line you used for the restart ?
> 
> Oren.
> 
> Serge E. Hallyn wrote:
> > All right I can't explain it at the moment, but exit(1) at
> > ckpt_coordinator() (on error) causes restart.c to exit with 0,
> > whereas return(ret) causes it to correctly exit with -1.
> > 
> > Without this, a restart whose kernel portion ends with say
> > -1 ends up returning from user-cr/restart.c with 0, so userspace
> > can't tell whether sys_restart succeeded or failed.  With the
> > patch, it fails correctly.
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  restart.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/restart.c b/restart.c
> > index e6e72ac..87899ba 100644
> > --- a/restart.c
> > +++ b/restart.c
> > @@ -933,7 +933,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
> >  		perror("restart failed");
> >  		ckpt_verbose("Failed\n");
> >  		ckpt_dbg("restart failed ?\n");
> > -		exit(1);
> > +		return ret;
> >  	}
> >  
> >  	ckpt_verbose("Success\n");

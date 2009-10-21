From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] Send checkpoint and restart debug info to a log
	file (v2)
Date: Wed, 21 Oct 2009 17:49:22 -0500
Message-ID: <20091021224922.GA5827@us.ibm.com>
References: <20091021210507.GA2098@us.ibm.com> <4ADF853F.6080807@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ADF853F.6080807-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Until now, debug data was sent to syslog.  That's not really
> > right.
> > 
> > This patch sends ckpt_debug output to a logfile provided by
> > the caller.  If no logfile is provided, then no debug output
> > is needed.  So the user can pass in -1 for the logfd to say
> > so.
> 
> I suggest to keep an option to write to the console/syslog too.
> Otherwise we may lose important debug info if a nasty crash
> occurs ...

Ok, that should be simple enough to tack on once the rest is
settled - just have ckpt_log() sent fmt+##args to both
do_ckpt_user_debug() (to write to user-provided file) and a
ckpt_syslog() which is a noop if !CONFIG_CHECKPOINT_DEBUG.

> > Note that this does not address the potential (inevitable?)
> > lockup of writing out a debug msg while checkpointing the
> > debug file.  In practice so far it seems to work rather well.
> > (with quite a bit of testing)
> 
> I believe the only concern here is that our debug code should
> not write any debug info while the respective inode is locked.

BTW it occurs to me that self-restart with a logfd must be kinda
hosed early on :)

> > This also means that we have to be more careful than we have
> > been about not writing out sensitive data.
> > 
> > This is pure RFC, not meant to be pretty.
> > 
> > The split into ckpt_debug and ckpt_err (see changelog) suggests
> > that we should rearrange (and be more consistent about) how and
> > when we print out debug info.  Left as an exercise for later.
> 
> I hate homework...
> 
> Besides, I think we need to address it now. This patch is pretty
> intrusive and will be painful when I fold to ckpt-v19. I do not
> want to go through the process twice.

Ok, why don't I take my best stab at this in my next patch.

> It's definitely time to come up with guidelines to when/where/how
> to add debugging output, and when/where/how to add error output.
> 
> In the 'how' section, besides avoiding leaking sensitive data, I'd
> like to come up with a canonical format that will be easy to read
> and to parse automatically (improve over ckpt_write_err).
> 
> Hmm... ckpt_write_err() should change too -- be written to the log
> instead.

Let's not be hasty - maybe duplicated, but an error message at the
end of the checkpoint file is still a nice sanity check for userspace
if they happened to checkpoint without a logfile.

> > Changelog:
> > 	Oct 21: split ckpt_debug into ckpt_debug and ckpt_err.
> > 		Git rid of the split by memory debug info etc.
> 
> The split is useful to control the amount of log.

It's a stupid split!  And I've never used it.  Besides, when a log is
for a single c/r, it's really not very big.

More practically, requiring userspace to pass over a flag
consisting of CKPT_DBG_MEM|CKPT_DBG|FILE|CKPT_DBG|TASK, and
handle corresponding usage flags, is not nice.

> > 		Since userspace actively asks for debug info, I
> > 		also made it not depend on CONFIG_CHECKPOINT_DEBUG.
> > 		We may want to put it back again to limit kernel
> > 		size, but for now it's a distraction, and I'm not
> > 		convinced it makes sense
> 
> Then add CONFIG_CHECKPOINT_LOGGING ?
> (automatically implied by CONFIG_CHECKPOINT_DEBUG)

Well...  for some reason I can't decide...  does that make sense?

Remember more config options means more ways for the code to
not compile.  Before adding one, I'd prefer to compile an image
with and without the ckpt_debugs (iow with the #defines under
#ifdef 0) and see how much size it really adds.  And in face right
now CONFIG_CHECKPOINT_DEBUG only directs creation of the extra restart
task debug info, which is only printed out when ctx->uflags & CKPT_DEBUG_ALL,
so that config option could go away entirely.

> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  arch/s390/kernel/compat_wrapper.S |    2 +
> >  arch/x86/mm/checkpoint.c          |   11 ++---
> >  checkpoint/checkpoint.c           |   22 ++++----
> >  checkpoint/files.c                |   29 +++++------
> >  checkpoint/memory.c               |   43 ++++++++-------
> >  checkpoint/namespace.c            |    3 -
> >  checkpoint/objhash.c              |   33 +++++++------
> >  checkpoint/process.c              |   85 +++++++++++++++----------------
> >  checkpoint/restart.c              |  101 +++++++++++++++++--------------------
> >  checkpoint/signal.c               |    5 +--
> >  checkpoint/sys.c                  |   94 ++++++++++++++++++++++------------
> >  drivers/char/tty_io.c             |   22 ++++----
> >  include/linux/checkpoint.h        |   85 ++++++++++++++++---------------
> >  include/linux/checkpoint_types.h  |    5 +-
> >  include/linux/syscalls.h          |    5 +-
> >  ipc/checkpoint.c                  |   13 ++---
> >  ipc/checkpoint_msg.c              |   13 ++---
> >  ipc/checkpoint_sem.c              |   13 ++---
> >  ipc/checkpoint_shm.c              |   15 ++---
> >  kernel/cred.c                     |    2 +-
> >  lib/Kconfig.debug                 |    4 +-
> >  mm/filemap.c                      |    2 +-
> >  mm/shmem.c                        |    2 +-
> >  net/checkpoint.c                  |   46 ++++++++--------
> >  net/ipv4/checkpoint.c             |   26 ++++-----
> >  net/unix/checkpoint.c             |   65 +++++++++++++-----------
> >  26 files changed, 380 insertions(+), 366 deletions(-)
> 
> Uhhh... when this matures from RFC to patch-for-inclusion, make
> sure to split it nicely for me ... please.

I'm not sure how split-able it is, but i'll do my best.

-serge

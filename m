From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH RFC] Send checkpoint and restart debug info to a log	file
	(v2)
Date: Wed, 21 Oct 2009 19:14:24 -0400
Message-ID: <4ADF95D0.8060806@librato.com>
References: <20091021210507.GA2098@us.ibm.com> <4ADF853F.6080807@librato.com>
	<20091021224922.GA5827@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091021224922.GA5827-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>
>> Serge E. Hallyn wrote:
>>> Until now, debug data was sent to syslog.  That's not really
>>> right.
>>>
>>> This patch sends ckpt_debug output to a logfile provided by
>>> the caller.  If no logfile is provided, then no debug output
>>> is needed.  So the user can pass in -1 for the logfd to say
>>> so.
>> I suggest to keep an option to write to the console/syslog too.
>> Otherwise we may lose important debug info if a nasty crash
>> occurs ...
> 
> Ok, that should be simple enough to tack on once the rest is
> settled - just have ckpt_log() sent fmt+##args to both
> do_ckpt_user_debug() (to write to user-provided file) and a
> ckpt_syslog() which is a noop if !CONFIG_CHECKPOINT_DEBUG.
> 
>>> Note that this does not address the potential (inevitable?)
>>> lockup of writing out a debug msg while checkpointing the
>>> debug file.  In practice so far it seems to work rather well.
>>> (with quite a bit of testing)
>> I believe the only concern here is that our debug code should
>> not write any debug info while the respective inode is locked.
> 
> BTW it occurs to me that self-restart with a logfd must be kinda
> hosed early on :)

Why would that be a problem ?  I actually think it's useful for
those doing self-restart:  you open a file, the kernel takes a
reference to it, then sys_restart() will eventually close that
file descriptor - but kernel still keeps a reference - so debug
data keeps flowing. When restart completes -- data is gone; If
restart fails - user will have information in that file.

> 
>>> This also means that we have to be more careful than we have
>>> been about not writing out sensitive data.
>>>
>>> This is pure RFC, not meant to be pretty.
>>>
>>> The split into ckpt_debug and ckpt_err (see changelog) suggests
>>> that we should rearrange (and be more consistent about) how and
>>> when we print out debug info.  Left as an exercise for later.
>> I hate homework...
>>
>> Besides, I think we need to address it now. This patch is pretty
>> intrusive and will be painful when I fold to ckpt-v19. I do not
>> want to go through the process twice.
> 
> Ok, why don't I take my best stab at this in my next patch.
> 
>> It's definitely time to come up with guidelines to when/where/how
>> to add debugging output, and when/where/how to add error output.
>>
>> In the 'how' section, besides avoiding leaking sensitive data, I'd
>> like to come up with a canonical format that will be easy to read
>> and to parse automatically (improve over ckpt_write_err).
>>
>> Hmm... ckpt_write_err() should change too -- be written to the log
>> instead.
> 
> Let's not be hasty - maybe duplicated, but an error message at the
> end of the checkpoint file is still a nice sanity check for userspace
> if they happened to checkpoint without a logfile.

Ok.

> 
>>> Changelog:
>>> 	Oct 21: split ckpt_debug into ckpt_debug and ckpt_err.
>>> 		Git rid of the split by memory debug info etc.
>> The split is useful to control the amount of log.
> 
> It's a stupid split!  And I've never used it.  Besides, when a log is
> for a single c/r, it's really not very big.

It may be stupid split!, yet it did prove very useful to me.
Maybe it's because you never debugged the memory checkpoint
page by page.

A typical scenario: you hit a bug -> you enable debugging ->
the bug disappears -> you disable debugging -> you hit the bug ...

IOW, debugging output in big doses affects the execution in a
way that makes heisen-bugs hide. Control over verbosity means you
get better chances at reproducing the behavior and still have
enough meaningful data.

> 
> More practically, requiring userspace to pass over a flag
> consisting of CKPT_DBG_MEM|CKPT_DBG|FILE|CKPT_DBG|TASK, and
> handle corresponding usage flags, is not nice.

I agree with you on about this. Maybe we want a better
interface ?

Which brings me to this random thought: maybe we want to
make the fourth argument of sys_{checkpoint,restart} a
structure, to make it easier to extend it in the future
without having to go throw a clone3-like hell...

Specifically, this structure could now be:

struct ckpt_args {
	int version;
	int logfd;
	int logmask;
};

(or use union checkpoint {} and union restart {} to tell
between checkpoint- and restart-related args.

> 
>>> 		Since userspace actively asks for debug info, I
>>> 		also made it not depend on CONFIG_CHECKPOINT_DEBUG.
>>> 		We may want to put it back again to limit kernel
>>> 		size, but for now it's a distraction, and I'm not
>>> 		convinced it makes sense
>> Then add CONFIG_CHECKPOINT_LOGGING ?
>> (automatically implied by CONFIG_CHECKPOINT_DEBUG)
> 
> Well...  for some reason I can't decide...  does that make sense?
> 
> Remember more config options means more ways for the code to
> not compile.  Before adding one, I'd prefer to compile an image
> with and without the ckpt_debugs (iow with the #defines under
> #ifdef 0) and see how much size it really adds.  And in face right
> now CONFIG_CHECKPOINT_DEBUG only directs creation of the extra restart
> task debug info, which is only printed out when ctx->uflags & CKPT_DEBUG_ALL,
> so that config option could go away entirely.
> 
>>> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>> ---
>>>  arch/s390/kernel/compat_wrapper.S |    2 +
>>>  arch/x86/mm/checkpoint.c          |   11 ++---
>>>  checkpoint/checkpoint.c           |   22 ++++----
>>>  checkpoint/files.c                |   29 +++++------
>>>  checkpoint/memory.c               |   43 ++++++++-------
>>>  checkpoint/namespace.c            |    3 -
>>>  checkpoint/objhash.c              |   33 +++++++------
>>>  checkpoint/process.c              |   85 +++++++++++++++----------------
>>>  checkpoint/restart.c              |  101 +++++++++++++++++--------------------
>>>  checkpoint/signal.c               |    5 +--
>>>  checkpoint/sys.c                  |   94 ++++++++++++++++++++++------------
>>>  drivers/char/tty_io.c             |   22 ++++----
>>>  include/linux/checkpoint.h        |   85 ++++++++++++++++---------------
>>>  include/linux/checkpoint_types.h  |    5 +-
>>>  include/linux/syscalls.h          |    5 +-
>>>  ipc/checkpoint.c                  |   13 ++---
>>>  ipc/checkpoint_msg.c              |   13 ++---
>>>  ipc/checkpoint_sem.c              |   13 ++---
>>>  ipc/checkpoint_shm.c              |   15 ++---
>>>  kernel/cred.c                     |    2 +-
>>>  lib/Kconfig.debug                 |    4 +-
>>>  mm/filemap.c                      |    2 +-
>>>  mm/shmem.c                        |    2 +-
>>>  net/checkpoint.c                  |   46 ++++++++--------
>>>  net/ipv4/checkpoint.c             |   26 ++++-----
>>>  net/unix/checkpoint.c             |   65 +++++++++++++-----------
>>>  26 files changed, 380 insertions(+), 366 deletions(-)
>> Uhhh... when this matures from RFC to patch-for-inclusion, make
>> sure to split it nicely for me ... please.
> 
> I'm not sure how split-able it is, but i'll do my best.

One way it to decide that we change the name ckpt_debug() to,
say, ckpt_log_debug(), then you introduce the new function in
on patch, and in following patches convert file by file.

Or, you just split it to first change ckpt_debug(), and then one
patch per file (or per subsystem). It's not bisect-able, but
that's ok because it's not going as is to the kernel - I'll
fold it anyway into ckpt-v19 clean patchset.

Oren.

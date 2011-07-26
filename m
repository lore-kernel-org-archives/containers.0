From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Tue, 26 Jul 2011 15:59:11 -0700
Message-ID: <20110726225911.GF14808@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<CAOS58YPqLSYi2xECUk4O5GG3s6aokT=VykmkL6UnAOzyHXNAgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOS58YPqLSYi2xECUk4O5GG3s6aokT=VykmkL6UnAOzyHXNAgQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Jul 23, 2011 at 05:53:46AM +0200, Tejun Heo wrote:
> Hello,
> 
> On Sat, Jul 23, 2011 at 2:25 AM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > Then there's the matter of unlinked files. How do you plan to deal
> > with those without kernel code?
> 
> /proc/PID/fd already provides access to deleted files perfectly well
> as most avid p0rn watchers would know (you can run mplayer on flash's
> deleted temp files). ;)

Yup, access to the unlinked file contents. This is an example where
things appear simple and complete in /proc yet it is insufficient.
Here's what you'll need:

The string "(deleted)" in a file name is, strictly speaking, ambiguous --
it does not mean the file is unlinked. You also can't infer that it is
unlinked by stat()'ing that path since a different file could have
been created in the same spot. For something unambiguous you'll
have to add that information to /proc somewhere. fdinfo doesn't seem
to be the right place since fds aren't unlinked -- files are. 

Then you've got to detect when they're the same unlinked file and share
the copy upon restart. Or they could be different unlinked files
with the same path in which case you should not share the copy. I suppose
you'll have to check the device and inode and then see if any other task
being checkpointed has it open... once for each of potentially thousands
of fds being checkpointed.

Then there's the case where you've got one unlinked dentry for the
file but a hardlink elsewhere. The /proc/PID/fd path won't point to the
hardlinked location. So in order for those to be the same file upon
restart you need to find the file somehow during checkpoint and/or
restart.

Finally these files often can be huge. Copying them elsewhere is a huge IO
burden compared to careful relinking of the file. IO that could be better
spent doing actual work.

We solved all that with "relinking". It's possible to make a relink()
syscall. The code I posted some time ago to containers@ can be easily
adapted for that -- I did so for my testing of those patches. I'm not
exactly sure how it would be done from userspace but I suspect it could
be done.

Perhaps you'll find a different and better way to solve all those
problems unlinked files present. I'd sincerely like to hear about it.

Cheers,
	-Matt

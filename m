From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: call_usermodehelper in containers
Date: Wed, 17 Feb 2016 21:17:21 -0600
Message-ID: <874md63dxa.fsf@x220.int.ebiederm.org>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131112004703.GB15377@kroah.com>
	<20131112061201.04cf25ab@tlielax.poochiereds.net>
	<528226EC.4050701@parallels.com>
	<20131112083043.0ab78e67@tlielax.poochiereds.net>
	<5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	<52860B6D.4090208@parallels.com> <1455320373.2890.5.camel@themaw.net>
	<56BF5511.6050606@virtuozzo.com> <1455495082.2941.32.camel@themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1455495082.2941.32.camel-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org> (Ian Kent's message of
	"Mon, 15 Feb 2016 08:11:22 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, skinsbursky-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org> writes:

> AFAICS kernel/kmod.c used to use create_singlethread_workqueue() and
>  queue_work() to perform umh calls, now it uses only queue_work() and
> the system_unbound_wq workqueue.
>
> Looking at the workqueue sub system there doesn't appear to be a way to
> create a workqueue with a thread runner thread, created within the
> process context at the time of workqueue creation, that then waits to
> run work. So there's no way to create a workqueue to run umh calls
> within a specific process context, such as that of a container, by using
> the workqueue subsystem as it is now.
>
> The problem being that the process context of the caller requesting umh
> isn't necessarily (and shouldn't be used because it could allow the
> caller to hijack the environment) the process context that needs to be
> used for the request.
>
> It looks like the reply to this thread from Oleg that demonstrates using
> child_reaper for the run context could be used though. Capturing the
> struct pid of child_reaper and then using that to locate the appropriate
> task context later (if it still exists) at request time could be used.
>
> That doesn't take care of working out when this should be captured or
> where to put it so it can be obtained at request time (which seems
> difficult in itself).

It would be really really nice if the user namespace could be used
for the where do we look at case.  As every other namespace already
has a pointer to the user namespace, and fundamentally the user
namespace is the permission boundary (from a namespace perspective).

So for the equivalent of kthreadd in a user namespace we need a thread
that has a full set of namespaces owned by the user namespaces.

On one side this is very easy to obtain if we look at the process that
sets core_pattern or mounts one of the nfs filesystems (such as the
filesystem that when mounted starts nfsd), and just fork a kernel thread
from it.

On another side perhaps what we want is a syscall call it start_umhd
that says repurpose the caller of this thread to handle future user mode
helper calls.  That we could tie to a user namespace quite easily.

This definitely does not play particularly nice with queue work and
friends, but that is just infrastructure and we can update user mode
helper to use something else reasonable as long as we have a solid
design.

Perhaps there is a combination of the two ideas that could work.
Instead of a syscall use the invocation of a service that needs a user
mode helper as a trigger to create such a launcher thread.

Eric

From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: restart (mktree) program usage
Date: Wed, 16 Sep 2009 23:14:37 -0400
Message-ID: <4AB1A99D.3020307@librato.com>
References: <20090909055636.GA27622@us.ibm.com> <4AA82B7C.8080107@librato.com>
	<20090917013546.GA30161@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090917013546.GA30161-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org] wrote:
> | 
> | 
> | Sukadev Bhattiprolu wrote:
> | > I have a usage question on the 'restart' (formerly mktree) program.
> | > 
> | > In the following container c/r case: 
> | > 
> | > 	- create a container
> | > 	- log in to the container,
> | > 	- restore filesystem(s) from snapshot
> | > 	- restart application from checkpoint
> | 
> | FWIW, I'd expect that future versions of 'restart' will be capable
> | of doing this entire setup, (filesystem(s) included), as it matures.
> | 
> | Note that this use case that you suggest will only work to restart
> | subtrees; it is unsuitable for full containers (with pids) because
> | the pid of init (1) will already be in use.
> 
> True. But if originally the application was started as:
> 
> 	Create container
> 	Login to contaienr

Actually, I'm not sure what you mean by "login to container" ?

> 	Set up filesystem
> 	Start application
> 

[One way to solve this is - after the file systems are setup, to
start a container inside that container :p ... or not].

Ok, let's assume that the application was started inside an existing
container to begin with, but was checkpointed as a whole-container --
with the ancestor(s) processes there -  then we basically have a
checkpoint image that holds more processes than we really care about.

So what ?  The simple fact is that the checkpoint image contains a
task with pid 1. So it won't restart unless in a new container.

I'd suggest checkpointing only a subtree, but that may not be an
option, e.g.  if the application already has some orphan processes -
unreachable under subtree !.

Or, I'd suggest to use a userspace tool to chop data away from the
checkpoint image (e.g. remove processes ...). But if you remove the
init process, you again face a problem with the orphans.

<warning> Here's a crazy idea: </warning>

Userspace maniuplation of the checkpoint image is a powerful tool.
I can imagine, for instance, a flag RESTART_I_AM_FINE_THANK_YOU with
which a process tells the restart to to let it be  (like the current
ghost tasks, but without exiting).

How is that useful ?  combine that with some checkpoint image tweaks,
and you can drop the init(1) task from the checkpoint image, and have
the real init task in the new container participate in the restart
without really restoring its state.... voila.

In fact, just like the proposed cradvise() would be able to tell the
kernel to use a given resource instead of recreating it from the
image, such a flag could tell the kernel to do so for processes.

Ok... a bit carried away. But maybe someone will find this idea not
only cool, but also useful :)

[Or, you start a new container, setup file systems, and then restart
into a new - nested - container :p ...]

Oren.

> The application would not be using the pid 1 right - even if the
> application was started from an rc script in the container ?
> 
> | 
> | Perhaps we should think of some "plugin" architecture for 'restart'
> | that will allow the user to ask it to execute some work at between
> | creating a new container and actually restarting into it ?
> 
> Yes, that would be really useful I think for things like restoring file
> system to its snapshot. Without that there is somewhat of an assymetry
> in starting an application in a container and restarting it from a
> checkpoint.

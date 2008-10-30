From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 14:28:17 -0500
Message-ID: <20081030192817.GA16340@us.ibm.com>
References: <1225219047.12673.182.camel@nimitz>
	<4909FAA8.5000107@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4909FAA8.5000107-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> I'm not sure why you say it's "un-linux-y" to begin with. But to the

The thing that is un-linux-y is specifically having user-space pass an
fd to the kernel from which it reads/writes.  LSMs had to go to a lot of
pain to avoid doing that for reading policy configuration at boot.

Of course it's now several years later, and moods and tastes change in
the kernel community, but I suspect it's still frowned upon.

> point, here are my thought:
> 
> 
> 1. What you suggest is to expose the internal data to user space and
> pull it. Isn't that what cryo tried to do ?  And the conclusion was
> that it takes too many interfaces to work out, code in, provide, and
> maintain forever, with issues related to backward compatibility and
> what not. In fact, the conclusion was "let's do a kernel-blob" !

Right, the problem with cryo was that it tried to do the checkpoint and
restart themselves at too fine-grained a level in terms of kernel-user
API.

What Dave is suggesting (as I understand it) is just changing the way
the data is shipped between kernel and user-space.  But to continue with
sys_checkpoint() and sys_restart().  So I think it's a less fundamental
change than you are thinking.

Now maybe eventually he's going to propose something more esotaric where
doing the mount() actually starts the checkpoint (that's where I figured
he'd be heading), but I think it would still be one action on the part
of userspace telling the kernel "do a checkpoint".

(Or am I wrong on that, Dave?)

[...]

(I'll let Dave respond to your other questions i.e. about what you gain)

> If this is only to be able to parallelize checkpoint - then let's discuss
> the problem, not a specific solution.

The specific problem is that you have userspace pass a file fd to the
kernel and kernel reading/writing to it, which is un-linuxy.

> > It enables us to do all the I/O from userspace: no in-kernel
> > sys_read/write().
> 
> What's so wrong with in-kernel vfs_read/write() ?  You mentioned deadlocks,

It's un-linux-y :)

[...]

> 5. Your suggestions leaves too many details out. Yes, it's a call for
> discussion. But still. Zap, OpenVZ and other systems build on experience
> and working code. We know how to do incremental, live, and other goodies.
> I'm not sure how these would work with your scheme.

Not sure what problems you envision, but taking the specific example of
pre-dump to prepare for a quick live migration, I could envision a
pre_checkpoint() system call creating the checkpoint data directory
and starting to dump out the data, and starting to copy that data
over the network (optimistically), after which the do_checkpoint()
syscall checks file timestamps and quickly dumps and network-copies the
data which has changed up until the container was frozen.

-serge

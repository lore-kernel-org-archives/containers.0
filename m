From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Checkpoint/restart (was Re: [PATCH 0/4] - v2 -  Object
	creation with a specified id)
Date: Tue, 22 Apr 2008 15:56:07 -0700
Message-ID: <1208904967.17117.51.camel__15234.5071699985$1208905102$gmane$org@nimitz.home.sr71.net>
References: <20080418054459.891481000@bull.net>
	<20080422193612.GA15835@martell.zuzino.mipt.ru>
	<1208890580.17117.14.camel@nimitz.home.sr71.net>
	<20080422210130.GA15937@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080422210130.GA15937-QDJVlCTZ4KWTKS93B3g+7KFoa47nwP16@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, nick-dnCCA748QAperShJXdIFYw@public.gmane.org, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2008-04-23 at 01:01 +0400, Alexey Dobriyan wrote:
> On Tue, Apr 22, 2008 at 11:56:20AM -0700, Dave Hansen wrote:
> > On Tue, 2008-04-22 at 23:36 +0400, Alexey Dobriyan wrote:> > 
> > > a) should mainline kernel have checkpoint/restart feature at all
> > > b) if yes, should it be done from kernel- or userspace?
> > > 
> > > Until agreement will be "yes/from userspace" such patches don't make
> > > sense in mainline.
> > 
> > What do you mean by "from kernel" or "from userspace"?
> 
> By "from userspace" I mean proposed interfaces and similar: usespace by
> special system calls puts some state of future object and then does
> normal system call which creates aforementioned object.
> 
> This can be used for PIDs, OK.
> 
> This can be used for SystemV shmem ids. But SystemV shmem also has
> (let's choose) uid/gid, atimes and actual content. How would restoration
> look like?
> 
> How to restore struct task_struct::did_exec ? Do execve(2)?
> 
> A was ptracing B at checkpoint moment...
> 
> Netdevices: stats, name, all sorts of flags, hw addresses, MTU
> 
> iptables rules.

Don't we already have interfaces to dump these out and restore them?  

My argument is this:  If we have interfaces that exist (like setting up
iptables rules) we shouldn't make a second interface *just* for
checkpoint/restart.  We have a hard enough time getting *one* interface
right for things, I can't imagine getting two right, and *keeping* them
right.

If the current interface is insufficient, we should first expand it in
such a way that it can be used for checkpoint.  That certainly won't
work in all cases.  fork(), for instance, doesn't take any arguments and
is going to be awfully hard to expand. :)

I'd love to hear some of your insights about how things like the current
iptables interfaces are insufficient for checkpoint/restart.

> These next ids are suitable, well, only for ids which is very, very small
> part of kernel state needed to restore group of processes.

I couldn't agree more.  This id setting mechanism would only be useful
for a small subset of the things we need during a restart.

-- Dave

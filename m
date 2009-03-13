From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Fri, 13 Mar 2009 17:53:57 +0100
Message-ID: <49BA8FA5.5030003__36868.712740443$1236963531$gmane$org@free.fr>
References: <1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226155755.GA1456@x200.localdomain>
	<20090310215305.GA2078@x200.localdomain>
	<49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com>
	<49BA8013.3030103@free.fr> <20090313163531.GA10685@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090313163531.GA10685-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Cedric Le Goater (legoater-GANU6spQydw@public.gmane.org):
>>> No, what you're suggesting does not suffice.
>> probably. I'm still trying to understand what you mean below :)
>>
>> Man, I hate these hierarchicals pid_ns. one level would have been enough, 
>> just one vpid attribute in 'struct pid*'
> 
> Well I don't mind - temporarily - saying that nested pid namespaces
> are not checkpointable.  It's just that if we're going to need a new
> syscall anyway, then why not go ahead and address the whole problem?
> It's not hugely more complicated, and seems worth it.

yes. agree. there's a thread going on that topic. i'm following it.

[ ... ] 

>> anyway, I think that some CLONE_NEW* should be forbidden. Daniel should
>> send soon a little patch for the ns_cgroup restricting the clone flags
>> being used in a container.
> 
> Uh, that feels a bit over the top.  We want to make this
> uncheckpointable (if it remains so), not prevent the whole action.
> After all I may be running a container which I don't plan on ever
> checkpointing, and inside that container running a job which i do
> want to migrate.

ok. i've been scanning the emails a bit fast. that would be fine 
and useful.

> So depending on if we're doing the Dave or the rest-of-the-world
> way :), we either clear_bit(pidns->may_checkpoint) on the parent
> pid_ns when a child is created, or we walk every task being
> checkpointed and make sure they each are in the same pid_ns.  
> Doesn't that suffice?

yes. this 'may_checkpoint' is a container level info so I wonder 
where you store it. in a cgroup_checkpoint ? sorry for jumping in 
and may be restarting some old topics of discussion.

C.

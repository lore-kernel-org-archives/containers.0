From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: CAP_SYS_ADMIN on restart(2)
Date: Wed, 15 Apr 2009 17:05:03 -0400
Message-ID: <49E64BFF.5080002__15907.7761731625$1239829890$gmane$org@cs.columbia.edu>
References: <20090410023207.GA27788@x200.localdomain>	<1239340031.24083.21.camel@nimitz>	<20090413091423.GA19236@x200.localdomain>	<49E4108A.8050201@cs.columbia.edu>	<20090414145830.GA27461@x200.localdomain>	<49E4D115.5080601@cs.columbia.edu>	<20090414204912.GA28458@x200.localdomain>	<20090414213934.GB17986@us.ibm.com>	<20090415192150.GC26994@x200.localdomain>	<1239827033.32604.167.camel@nimitz>
	<20090415203920.GA5475@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090415203920.GA5475-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> On Wed, 2009-04-15 at 23:21 +0400, Alexey Dobriyan wrote:
>>> Is sysctl to control CAP_SYS_ADMIN on restart(2) OK?
>> If the point is not to let users even *try* restarting things if it
>> *might* not work, then I guess this might be reasonable.  
>>
>> If the goal is to increase security by always requiring CAP_SYS_ADMIN
>> for "dangerous" operations, I fear it will be harmful.  We may have
>> people adding features that are not considering the security impact of
>> what they're doing just because the cases they care about all require
>> privilege.
> 
> Nah, I disagree.  (Or put another way, that wouldn't be the goal)
> There are two administrators we want to satisfy:
> 
> 1. the one who wants his users to do partial checkpoints, but doesn't
> want to risk giving away any privilege at all in the process.  He'll
> be satisified by setting restart(2) to not require cap_sys_admin,
> and his users just won't be able to do a whole container.  A lot of
> users will be happy with that (though no SYSVIPC support, then).

There is also a middle way: use setuid program to allow creation
of a new namespace (under your favorite policy), then drop the
privileges and continue as unprivileged inside that container.

IOW, don't make the initial container-creation a barrier for the
entire operation.

Oren.

> 
> 2. the one who may have one or two users who he trusts to do
> checkpoint/restart, but otherwise doesn't want even the slightest
> risk of other users using restart, and maybe finding an exploit.
> That one is probably the more common admin, and he'll be satisified
> with requiring CAP_SYS_ADMIN for all restart(2)'s, since he's ok
> risking giving extra privilege to the ones he trusts.
> 
> And meanwhile, by virtue of leaving (1) supported, we are still
> more under the gun to make sure that everything restart(2) does
> is properly checked.
> 
>> What would the goal be?
>>
>> -- Dave
> 
> -serge
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

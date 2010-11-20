From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Sat, 20 Nov 2010 13:11:35 -0500 (EST)
Message-ID: <4CE69B8C.6050606@cs.columbia.edu>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>
	<4CD3CE29.2010105@kernel.org>
	<20101106053204.GB12449@count0.beaverton.ibm.com>
	<20101106204008.GA31077@sundance.ccs.neu.edu>
	<4CD5D99A.8000402@cs.columbia.edu>
	<20101107184927.GF31077@sundance.ccs.neu.edu>
	<4CD72150.9070705@cs.columbia.edu> <4CE3C334.9080401@kernel.org>
	<20101117153902.GA1155@hallyn.com> <4CE3F8D1.10003@kernel.org>
	<20101119041045.GC24031@hallyn.com> <4CE683E1.6010500@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CE683E1.6010500-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-3ImXcnM4P+0@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


login as: orenl
Using keyboard-interactive authentication.
Password:
Access denied
Using keyboard-interactive authentication.
Password:
Last login: Fri Nov 19 10:17:21 2010 from 192.117.42.81.static.012.net.il
499:takamine[~]$ pine
  PINE 4.64   COMPOSE MESSAGE                                                                     
Folder: Drafts  8 Messages  +

To      : Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc      : Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
          Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>,
          Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>,
          linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
          xemul-3ImXcnM4P+0@public.gmane.org,
          "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
          Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Fcc     : imap://ol2104-u1PCbA9B4pbMrJhsLK8IO4dd74u8MsAO@public.gmane.org/Sent
Attchmnt:
Subject : Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
----- Message Text -----
Hi,

[continuation of discussion of kernel vs userspace c/r approach]
part I: perpsectice about the types of scopes of c/r in discussion
part II: linux-cr design adn objectives
part III: comparison kernel/userspace approaches


PART III:  ==SOME TECHNICAL ASPECTS==

Important to know about userspace (DMTCP example) before presenting a
comparison between kernel and userspace approaches:

DMTCP has two components: 1) c/r-engine to save/restore process state,
and 2) glue to restart processes out of their original context. They
are _orthogonal_: the glue can be used with of other c/r-engines, like
linux-cr. This discussion refers to the c/r-engine _only_.

Focusing on the c/r-engine of DMTCP - it uses syscall interposition
for three reasons:

1) To take control of processes at checkpoint
2) To always track state of resources not visible to userspace
3) To virtualize identifiers after restart

#1 is needed because processes saves their own state (and need to run
the checkpoint code for that).

#2 is needed because the kernel does not expose all state, and #3 is
needed because the kernel does not give ways to restore all state. So
these two logics are used to mirror in userspace functionality that
already exists in the kernel.

The main advantages of the approach: (a) portability to other system
(like BSD), though with considerable effort (b) it's "good enough" for
several use-cases, without kernel changes.

Putting the c/r-engine in the kernel provides many advantages, which I
summarize in the following table:

category        linux-cr                        userspace
--------------------------------------------------------------------------------
PERFORMANCE     has _zero_ runtime overhead     visible overhead due to syscalls
                                                interposition and state tracking
                                                even w/o checkpoints;

OPTIMIZATIONS   many optimizations possible     limited, less effective
                only in kernel, for downtime,   w/ much larger overhead.
                image size, live-migration

OPERATION       applications run unmodified     to do c/r, needs 'controller'
                                                task (launch and manage _entire_
                                                execution) - point of failure.
                                                restricts how a system is used.

PREEMPTIVE      checkpoint at any time, use     processes must be runnable and
                auxiliary task to save state;   "collaborate" for checkpoint;
                non-intrusive: failure does     long task coordination time
                not impact checkpointees.       with many tasks/threads. alters
                                                state of checkpointee if fails.
                                                e.g. cannot checkpoint when in
                                                vfork(), ptrace states, etc.

COVERAGE        save/restore _all_ task state;  needs new ABI for everything:
                identify shared resources; can  expose state, provide means to
                extend for new kernel features  restore state (e.g. TCP protocol
                easily                          options negotiated with peers)

RELIABILITY     checkpoint w/ single syscall;   non-atomic, cannot find leaks
                atomic operation. guaranteed    to determine restartability
                restartability for containers

USERSPACE GLUE  possible                        possible

SECURITY        root and non-root modes         root and non-root modes
                native support for LSM

MAINTENANCE     changes mainly for features     changes mainly for features;
                                                create new ABI for features

I'm not saying Gene's work isn't good - on the contrary, it's a fine
piece of engineering. However, the part of it that does c/r poses many 
constraints that limits the generality, mode of use, and performance of 
the whole. That may be enough for Tejun, for your cluster. But not 
for other users of the technology.

And by all means, I intend to cooperate with Gene to see how to
make the other part of DMTCP, namely the userspace "glue", work on
top of linux-cr to have the benefits of all worlds !

All in all, kernel c/r is far more generic and less restrictive than
userspace, can provide nice guarantees, and has superior performance.
It can do everything the a userspace c/r can do, and much more - and
that "much more" is crucial for important use cases.

Last word about maintenance - once the core code is in mainline (which
means a code "spike"), experience (both kernel/userspace) shows that
both code and image format hardly change. The format is tied to specific
set of features supported (i.e. kernel versions) so that the kernel
does not need to maintain backward compatibility.

Thanks,

Oren

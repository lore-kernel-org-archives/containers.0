From: Joseph Ruscio <jruscio-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Wed, 6 Aug 2008 08:41:10 -0700
Message-ID: <3A99F254-E9B3-484B-85B0-29023ADA04C4@evergrid.com>
References: <4891E849.1050701@cs.columbia.edu>
	<20080731175058.GI22403@hawkmoon.kerlabs.com>
	<48920EA0.1060608@cs.columbia.edu>
	<20080801102600.GJ22403@hawkmoon.kerlabs.com>
	<48931A7E.1040302@cs.columbia.edu>
	<20080801180038.GL22403@hawkmoon.kerlabs.com>
	<48935B4D.7070302@cs.columbia.edu>
	<20080804101608.GA4081@localdomain>
	<4897BCE0.1080508@cs.columbia.edu>
	<1FA56146-7C30-4C36-982D-A50AA8BC8392@evergrid.com>
	<20080805091955.GA5027@localdomain>
	<48987DE7.3060408@cs.columbia.edu>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48987DE7.3060408-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


On Aug 5, 2008, at 9:20 AM, Oren Laadan wrote:

>
>
> Louis Rilling wrote:
>> On Mon, Aug 04, 2008 at 08:51:37PM -0700, Joseph Ruscio wrote:
>>> As somewhat of a tangent to this discussion, I've been giving some
>>> thought to the general strategy we talked about during the summit.  
>>> The
>>> checkpointing solution we built at Evergrid sits completely in  
>>> userspace
>>> and is soley focused on checkpointing parallel codes (e.g. MPI).  
>>> That
>>> approach required us to virtualize a whole slew of resources (e.g.  
>>> PIDs)
>>> that will be far better supported in the kernel through this  
>>> effort. On
>>> the other hand, there isn't anything inherent to checkpointing the  
>>> memory
>>> in a process that requires it to be in a kernel. During a restart,  
>>> you
>>> can map and load the memory from the checkpoint file in userspace as
>>> easily as in the kernel. Since the cost of checkpointing HPC codes  
>>> is
>>
>> Hmm, for unusual mappings this may be not so easy to reproduce from
>> userspace if binaries are statically linked. I agree that with
>> dynamically linked applications, LD_PRELOAD allows one to record the
>> actual memory mappings and restore them at restart.
>
> I second that: unusual mapping can be hard to reproduce.
>
> Besides, several important optimization are difficult to do in user- 
> space,
> if at all possible:
>
> * detecting sharing (unless the application itself gives the OS an  
> advice -
> more on this below); In the kernel, this is detected easily using  
> the inode
> that represents a shared memory region in SHMFS
>
>
> * detecting (and restoring) COW sharing: process A forks process B,  
> so at
> least initially the private memory of both is the same via COW; this  
> can be
> optimized to save the memory of only one instead of both, and  
> restore this
> COW relationship on restart.

Both of these are possible from userspace, but agreeably more  
complicated. Also agree that statically linked binaries are not really  
feasible in user-space.


> * reducing checkpoint downtime using the COW technique that I  
> described at
> the summit: when processes are frozen, mark all dirty pages COW and  
> keep a
> reference, and write-back the contents only after the container is  
> unfrozen.

Our user-space implementation already has a complete concurrent (i.e.  
COW) checkpointing implementation where the "freeze" period lasts only  
the length of time it takes to mprotect() the allocated memory  
regions. So I don't necessarily agree that these optimizations require  
kernel access.

> Eh... and, yes, live migration :)

  User-space live migration of a "batch" process e.g. one taking place  
in an MPI job is quite trivial. User-space live migration of something  
like a database is not that hard assuming you have a cooperative load  
balancer or proxy on the front end.

I'm not advocating for implementing this in user-space. I am in  
complete agreement that this effort should result in code that  
completely checkpoints a Container in the kernel. My question was  
whether there are situations where it would be advantageous for user- 
space to have the option of instructing/hinting the kernel to ignore  
certain resources that it would handle itself. Most of the use-cases  
I'm thinking of come from the different styles of implementations I've  
seen in the HPC space, where our implementation (and a lot of others)  
are focused.

MPI codes require coordination between all the different processes  
taking part to ensure that the checkpoints are globally consistent.  
MPI implementations that run on hardware such as Infiniband would most  
likely want the container checkpointing to ignore all of the pinned  
memory associated with the RDMA operations so that the coordination  
and recreation of MPI communicator state could be handled in user- 
space. When working with inflexible process checkpointers, MPI  
coordination routines often must completely teardown all communicator  
state prior to invoking the checkpoint, and then recreate all the  
communicators after the checkpoint. On very large scale jobs, this is  
expensive.

As another example HPC applications can create local scratch files of  
several GB in /tmp. It may not be necessary to migrate these files,  
but if user-space has no way to mark a particular file, "local files",  
or files in general as being ignored, then we'll have to copy these  
during a migration or a checkpoint.

I don't suppose anyone is attending Linuxworld in San Francisco this  
week? I'd be more then happy to grab a coffee and talk about some of  
this. I stopped by the OpenVZ booth but none of the devs are around.

thanks,
Joe

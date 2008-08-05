From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Tue, 05 Aug 2008 12:20:55 -0400
Message-ID: <48987DE7.3060408@cs.columbia.edu>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080805091955.GA5027@localdomain>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: Joseph Ruscio <jruscio-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Mon, Aug 04, 2008 at 08:51:37PM -0700, Joseph Ruscio wrote:
>> As somewhat of a tangent to this discussion, I've been giving some  
>> thought to the general strategy we talked about during the summit. The  
>> checkpointing solution we built at Evergrid sits completely in userspace 
>> and is soley focused on checkpointing parallel codes (e.g. MPI). That 
>> approach required us to virtualize a whole slew of resources (e.g. PIDs) 
>> that will be far better supported in the kernel through this effort. On 
>> the other hand, there isn't anything inherent to checkpointing the memory 
>> in a process that requires it to be in a kernel. During a restart, you 
>> can map and load the memory from the checkpoint file in userspace as 
>> easily as in the kernel. Since the cost of checkpointing HPC codes is 
> 
> Hmm, for unusual mappings this may be not so easy to reproduce from
> userspace if binaries are statically linked. I agree that with
> dynamically linked applications, LD_PRELOAD allows one to record the
> actual memory mappings and restore them at restart.

I second that: unusual mapping can be hard to reproduce.

Besides, several important optimization are difficult to do in user-space,
if at all possible:

* detecting sharing (unless the application itself gives the OS an advice -
more on this below); In the kernel, this is detected easily using the inode
that represents a shared memory region in SHMFS

* detecting (and restoring) COW sharing: process A forks process B, so at
least initially the private memory of both is the same via COW; this can be
optimized to save the memory of only one instead of both, and restore this
COW relationship on restart.

* reducing checkpoint downtime using the COW technique that I described at
the summit: when processes are frozen, mark all dirty pages COW and keep a
reference, and write-back the contents only after the container is unfrozen.

Eh... and, yes, live migration :)

> 
>> fairly dominated by checkpointing their large memory footprints, memory 
>> checkpointing is an area of ongoing research with many different 
>> solutions.
>>
>> It might be desirable for the checkpointing implementation to be modular 
>> enough that a userspace application or library could select to handle 
>> certain resources on their own. Memory is the primary one that comes to 
>> mind.
> 
> I definitely agree with you about this flexibility. Actually in
> Kerrighed, during the next 3 years, we are going to study an API for
> collaborative checkpoint/restart between kernel and userspace, in order to
> allow such HPC apps to checkpoint huge memory efficiently (eg. when reaching
> states where saving small parts is enough), or to rebuild their data from
> partial/older states.
> I hope that this study will bring useful ideas that could be applied to
> containers as well.

Indeed it would add flexibility if an interface exists. One example is for
network connections in the case of a distributed MPI application, or if a
specific (otherwise unsupported for CR) device is involved.

As for memory, a clever way to hint the system about what parts of memory
are important, is to use something like an madvice() with a new flag, to
mark areas of interest/dis-interest.  Throw in a mechanism to notify tasks
(who request to be notified) of an upcoming checkpoint, end of successful
checkpoint, and completion of a successful restart - and you've got it all.

Oren.

> 
> Thanks,
> 
> Louis
> 

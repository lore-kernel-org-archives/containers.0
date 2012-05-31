From: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: container disk quota
Date: Thu, 31 May 2012 20:31:42 +0800
Message-ID: <4FC764AE.4070404@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<4FC731C1.5000903@parallels.com>
Reply-To: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4FC731C1.5000903-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Glauber,

Thanks for you comments!

On 05/31/2012 04:54 PM, Glauber Costa wrote:

> On 05/30/2012 06:58 PM, jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
>> Hello All,
>>
>> According to glauber's comments regarding container disk quota, it
>> should be binded to mount
>> namespace rather than cgroup.
>>
>> Per my try out, it works just fine by combining with userland quota
>> utilitly in this way.
> that's great.
> 
> I'll take a look at the patches.
> 
> 
>>
>> * Modify quotactl(2) to examine if the caller is invoked inside
>> container.
>>    implemented by checking the quota device name("rootfs" for lxc
>> guest) or current pid namespace
>>    is not the initial one, then do mount namespace quotactl if
>> required, or goto
>>    the normal quotactl procedure.
> 
> I dislike the use of "lxc" name. There is nothing lxc-specific in this,
> this is namespace-specific. lxc is just one of the container solutions
> out there, so let's keep it generic.

I think I should forget all things regarding LXC, just treat it as a new
quota feature with regard to namespace.

>>
>> * Also, I have not handle a couple of things for now.
>>    . I think the container quota should be isolated to Jan's fs/quota/
>> directory.
>>    . There are a dozens of helper routines at general quota, e.g,
>>      struct if_dqblk<->  struct fs_disk_quota converts.
>>      dquot space and inodes bill up.
>>      They can be refactored as shared routines to some extents.
>>    . quotastats(8) is not teached to aware container for now.
>>
>> Changes in quota userland utility:
>> * Introduce a new quota format string "lxc" to all quota control
>> utility, to
>>    let each utility know that the user want to run container quota
>> control. e.g:
>>    quotacheck -cvugm -F "lxc" /
>>    quotaon -u -F "lxc" /
>>    ....
>>
>> * Currently, I manually created the underlying device(by editing cgroup
>>    device access list and running mknod /dev/sdaX x x) for the rootfs
>>    inside containers to let the cache mount points routine pass for
>>    executing quotacheck against the "/" directory.  Actually, it can be
>>    omitted here.
>>
>> * Add a new quotaio_lxc.c[.h] for container quota IO, it basically
>> same to
>>    VFS quotaio logic, I just hope to isolate container stuff here.
>>
>> Issues:
>> * How to detect quotactl(2) is launched from container in a reasonable
>> way.
> 
> It's a system call. It is always called by a process. The process
> belongs to a namespace. What else is needed?

nothing now. :)

> 
>> * Do we need to let container quota works for cgroup combine with
>> unshare(1)?
>>    Now the patchset is mainly works for lxc guest.  IMHO, it can be
>> used outside
>>    guest if the user desired.  In this case, the quota limits can take
>> effort
>>    among different underlying file systems if they have exported quota
>> billing
>>    routines.
> 
> I still don't understand what is the business of cgroups here. If you
> are attaching it to mount namespace, you can always infer the context
> from the calling process. I still need to look at your patches, but I
> believe that dropping the "feature" of manipulating this from outside of
> the container will save you a lot of trouble.

Yup, just treat it to be namespace specific, there is nothing need to
consider with cgroup interface.

> 
> Please note that a process can temporarily join a namespace with
> setns(). So you can have a *utility* that does it from the outer world,
> but the kernel has no business with that. As far as we're concerned, I
> believe that you should always get your context from the current
> namespace, and forbid any usage from outside.

I'll more investigation for that.

> 
>> * The hash table list defines(hash table size)for dquot caching for
>> each type is
>>    referred to kernel/user.c, maybe its better to define an array
>> separatly for
>>    performance optimizations.  Of course, that's all depending on my
>> current
>>    implementation is on the right road. :)
>>
>> * Container quota statistics, should them be calculated and exposed to
>> /proc/fs/quota?  If the underlying file system also enabled with
>> quotas, they will be
>>    mixed up, so how about add a new proc file like "ns_quota" there?
> No, this should be transferred to the process-specific proc and them
> symlinked. Take a look at "/proc/self".
> 
>>
>> * Memory shrinks acquired from kswap.
>>    As all dquot are cached in memory, and if the user executing
>> quotaoff, maybe
>>    I need to handle quota disable but still be kept at memory.
>>    Also, add another routine to disable and remove all quotas from
>> memory to
>>    save memory directly.
> 
> I didn't read your patches yet, so take it with a grain of salt here.
> But I don't understand why you make this distinction of keeping it in
> memory only.
> 
> You could keep quota files outside of the container, and then bind mount
> them to the current location in the setup-phase.

I have tried to keep quota files outsides originally, but I changed my
thoughts afterwards, because of three reasons at that time:

1) The quota files could be overwrote if the container's rootfs is
located at the root directory of a storage partition, and this partition
is mounted with quota limits enabled.

2) To deal with quota files, looks I have to tweak up
quota_read()/quota_write(), assuming ext4, which are corresponding to
ext4_quota_read()/ext4_quota_write().

3) As mount namespace could be created and destroyed at any stage,
it has no memory to recall which inodes are quota files. however, quota
tools need to restore a few things from those files I remember.
but can not recalled all of them for now. :( I'll do some check up to
refresh my head in this point.

Sure, considering that we can bind mount them at setup phase, the first
concern could be ignored.


Thanks,
-Jeff

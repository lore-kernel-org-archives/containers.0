From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 00/16][cr][v3]: C/R file owner, locks, leases
Date: Wed, 04 Aug 2010 14:03:50 -0400
Message-ID: <4C59AB86.6080202__24745.5116863877$1280945212$gmane$org@cs.columbia.edu>
References: <1280877097-12377-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1280918720.2566.18.camel@localhost>
	<20100804172649.GM2927@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100804172649.GM2927-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



On 08/04/2010 01:26 PM, Matt Helsley wrote:
> On Wed, Aug 04, 2010 at 11:45:20AM +0100, Steven Whitehouse wrote:
>> Hi,
>>
>> On Tue, 2010-08-03 at 16:11 -0700, Sukadev Bhattiprolu wrote:
>>> Checkpoint/restart file owner, file-locks and file-lease information.
>>>
>> Can you explain roughly how this is intended to work, or point me at a
>> document explaining it?
>>
>> I'm trying to figure out how the file lock checkpoint will work with
>> cluster filesystems, or if there needs to be a mechanism to turn this
>> feature off for those filesystems. What prevents the lock state changing
>> in an incompatible way between the checkpoint and the restore?
>

Hi Steve,

In addition to Matt's reply -

Checkpoint/restart _assumes_ that there exists a mechanism to keep
the filesystem state _unchanged_ between checkpoint and restart.

For example, one can kill the application after checkpoint and keep
the filesystem from being touched.
A more likely scenario is to use a filesystem's snapshot/backup
solution during checkpoint to ensure a pristine copy for restart.
In particular, there needs to be a mechanism to accomplish this
in a cluster filesystem, or rely on dedicated userspace tools.

So at restart, the filesystem is assumed to be visible and in the
same state as before. That state also includes locks etc.

Also, c/r has a mechanism to detect cases where a file in use by
the checkpoint application(s) is shared with a task that is not
being checkpointed. In this case, checkpoint will fail, to prevent
inconsistencies.

(I also imagine that often a cluster filesystem is used by parallel
applications - which in turn require some support to be checkpointed
in a consisted manner).

Oren.


> Hi Steve,
>
> [ I'm just going to address your cluster filesystem question and let
>    Suka answer your questions on these patches. ]
>
> 	Open files whose file operations structs are missing the
> .checkpoint operation cause checkpoint to fail. We haven't added a
> .checkpoint operation to cluster filesystems because of the kinds of
> issues you're referring to.
>
> 	I don't think there are any file locks/leases which do not
> require opening the file(s) in question. That means file locks
> and leases in cluster filesystems should also cause checkpoint
> to fail.
>
> 	Each cluster filesystem probably needs some special care when
> considering the use of the generic_file_checkpoint operation.
>
> 	Using generic_file_checkpoint is appropriate when we have some
> way to get a consistent image of the filesystem at the time checkpoint
> takes place. How that happens is largely up to the userspace tools
> called user-cr. Device-mapper snapshots, fsfreezer + rsync, and
> filesystem snapshots will all work. Of course those tools usually don't
> save more volatile state information like locks.
>
> 	It's quite possible cluster filesystems will need their own
> .checkpoint file operations. generic_file_checkpoint is composed of a few
> smaller functions which could make writing such ops easier. For example,
> we've already reused the smaller functions in .checkpoint operations for
> anon_inode-based interfaces, pipes, fifos, and more,
>
> 	What it may come down to is this: How do you backup a cluster
> filesystem? If there's already a backup method that works then we can
> write the .checkpoint operation to rely on it. Often that means we
> can use generic_file_checkpoint. The "backup method" should be
> something which can be invoked by the userspace checkpoint/restart tools
> (user-cr). If the backup method is too slow we can work on
> improving it or we can try something else.
>
> 	So perhaps the best thing we can do to help you is learn how
> folks backup their cluster filesystems. Got any pointers to basic info
> on that?
>
> Cheers,
> 	-Matt Helsley
>
>

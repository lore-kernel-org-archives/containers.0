From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Sun, 21 Mar 2010 17:36:13 -0400
Message-ID: <4BA6914D.8040007__43671.1036404178$1269207450$gmane$org@cs.columbia.edu>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>	<20100320044310.GC2887@count0.beaverton.ibm.com>	<20100321172703.GC4174@shareable.org>	<20100321194019.GA11714@hallyn.com>
	<4BA68884.3080003@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BA68884.3080003-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org



Daniel Lezcano wrote:
> Serge E. Hallyn wrote:
>> Quoting Jamie Lokier (jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org):
>>   
>>> Matt Helsley wrote:
>>>     
>>>>> That said, if the intent is to allow the restore to be done on
>>>>> another node with a "similar" filesystem (e.g. created by rsync/node
>>>>> image), instead of having a coherent distributed filesystem on all
>>>>> of the nodes then the filename makes sense.
>>>>>         
>>>> Yes, this is the intent.
>>>>       
>>> I would worry about programs which are using files which have been
>>> deleted, renamed, or (very common) renamed-over by another process
>>> after being opened, as there's a good chance they will successfully
>>> open the wrong file after c/r, and corrupt state from then on.
>>>     
>> Userspace is expected to back up and restore the filesystem, for
>> instance using a btrfs snapshot or a simple rsync or tar.
>>
>>   
> That does not solve the problem Jamie is talking about.
> A rsync or a tar will not see a deleted file and using a btrfs to have 
> the CR to work with the deleted files is a bit overkill, no ?

Let's separate the issues of file system snapshot and deleted files.

1) File system snapshot:
------------------------
The requirement is to preserve the file system state between the time
of the checkpoint and the time of the restart, because userspace will
expect it to remain the same.

The alternatives are:

a) Use capable file system, like brfs, or (modified) nilfs.

b) Userspace saves the state e.g. w/ tar or rsync (maybe incremental)

c) Assume/expect that the file system isn't modified between checkpoint
and restart (e.g. if we use c/r to suspend a user's session)

d) Expect userspace to adapt to changes if they occur, e.g. by having
the application be aware of the possibility, or by providing a wrapper
that will do some magic prior to restart (by looking at the checkpoint
image).

Options a,b,c are all transparent to the application, while option
d required that applications become aware of c/r. That's ok, but our
primary goal is to be generic enough to unmodified applications.

2) Deleted files:
-----------------
The requirement is that at restart we'll be able to restore the file
point in the kernel to a deleted file with same properties and contents
as it was at the time of the checkpoint.

The alternatives we considered are:

e) For each deleted file, save the contents of that file as part of
the checkpoint image;
At restart - create a new file, populate with the contents, open it
(to get an active file pointer), and finally unlink it, so it is -
again - deleted.

f) At checkpoint time, create a file (from scratch) in a dedicated
area of the file system (userspace configurable?), and copy the
contents of the deleted file to this file. Only save the file system
state after this is done.
At restart, open the alternative file instead, and then immediately
delete it.

g) At checkpoint time, re-link the file to a dedicated area of the
file system. This requires support from the underlying file system,
of course. For instance, it's trivial for ext2,3 but IIRC will need
help for ext4. Re-linking is essentially attaching a new filename
to an existing inode that is still referenced but is otherwise not
reachable - and make it reachable again.
At restart, open the re-linked file and then immediately delete it.

> I have another question about the deleted files. How is handled the case 
> when a process has a deleted mapped file but without an associated file 
> descriptor ?
> 

It works the same as with non-deleted files (assuming that we know
how to handle delete files in general, e.g. options e,d,f above):

To checkpoint a task's mm we loop through the vma's and checkpoint
them. For a vma that corresponds to a mapped file, we first save
the vma->vm_file. In turn, for a file pointer we save the filename,
properties, credentials. A file pointer is saved as an independent
object - and is assigned a unique id - objref. The state of the vma
will indicate indicate this objref.

At restart, we will first see the file pointer object, and will
open the file to create a corresponding file pointer. Later when
we restore the vma, we'll locate the (new) file pointer using the
objref and use it in mmap.

Oren.


>> If we detect anything which really is not supported (for instance
>> inotify for now) then we fail and leave a log message explaining the
>> failure.
>>   
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

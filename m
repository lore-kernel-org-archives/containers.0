From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v10][PATCH 08/13] Dump open file descriptors
Date: Mon, 01 Dec 2008 16:20:05 -0500
Message-ID: <49345505.5050104__28738.431496504$1228166667$gmane$org@cs.columbia.edu>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>	
	<1227747884-14150-9-git-send-email-orenl@cs.columbia.edu>	
	<20081128101919.GO28946@ZenIV.linux.org.uk>	
	<1228153645.2971.36.camel@nimitz>
	<493447DD.7010102@cs.columbia.edu>
	<1228164679.2971.91.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1228164679.2971.91.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Mon, 2008-12-01 at 15:23 -0500, Oren Laadan wrote:
>> Verifying that the size doesn't change does not ensure that the table's
>> contents remained the same, so we can still end up with obsolete data.
> 
> With the realloc() scheme, we have virtually no guarantees about how the
> fdtable that we read relates to the source.  All that we know is that
> the n'th fd was at this value at *some* time.
> 
> Using the scheme that I just suggested (and you evidently originally
> used) at least guarantees that we have an atomic copy of the fdtable.

It doesn't matter if the fdtable changes while we scan the fd's or
after we're done scanning the fd's, does it ?  the end result is the
same - inconsistency.

> Why is this done in two steps?  It first grabs a list of fd numbers
> which needs to be validated, then goes back and turns those into 'struct
> file's which it saves off.  Is there a problem with doing that
> fd->'struct file' conversion under the files->file_lock?

Again, say we get all the struct file for all those fd's. Now we have to
drop the lock, and start processing the struct files. So what if at this
point the fdtable changes ?  we still end up with potentially inconsistent
state.

We can do it atomically or non-atomically, I couldn't care less.

My argument is the following:
1) Ideally, the state should not change while we are checkpointing
2) If the state changes, then the behavior is undefined (but the kernel
   should not crash, of course).
3) It should be the userspace responsibility to ensure that (1) holds
   (for instance, that all tasks sharing these resources are frozen
   during the checkpoint)

#2 will be an uncommon event - a programmer/user/administrator mistake.
Kernel may help enforce this rule, but catching all such cases will be
expensive as it means looping through all tasks for each new resource.

As a first step, we can ensure that all threads of a process are frozen
at checkpoint time (and prevent unfreeze until checkpoint is over). But
that will not cover a clone() with CLONE_FS. And this will be the same
for other namespaces later.

Oren.

From: Joseph Ruscio <jruscio-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Wed, 6 Aug 2008 09:15:46 -0700
Message-ID: <FE4D936E-06F1-45D2-8E7C-85D87149BDC0@evergrid.com>
References: <20080731135703.GC22403@hawkmoon.kerlabs.com>
	<4891D5C2.8090000@cs.columbia.edu>
	<20080731155856.GH22403@hawkmoon.kerlabs.com>
	<4891E849.1050701@cs.columbia.edu>
	<20080731175058.GI22403@hawkmoon.kerlabs.com>
	<48920EA0.1060608@cs.columbia.edu>
	<20080801102600.GJ22403@hawkmoon.kerlabs.com>
	<48931A7E.1040302@cs.columbia.edu>
	<20080801180038.GL22403@hawkmoon.kerlabs.com>
	<48935B4D.7070302@cs.columbia.edu>
	<20080804101608.GA4081@localdomain>
	<4897BCE0.1080508@cs.columbia.edu>
	<1FA56146-7C30-4C36-982D-A50AA8BC8392@evergrid.com>
	<1217953429.10907.27.camel@nimitz>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217953429.10907.27.camel@nimitz>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
List-Id: containers.vger.kernel.org


On Aug 5, 2008, at 9:23 AM, Dave Hansen wrote:

> On Mon, 2008-08-04 at 20:51 -0700, Joseph Ruscio wrote:
>> It might be desirable for the checkpointing implementation to be
>> modular enough that a userspace application or library could select  
>> to
>> handle certain resources on their own. Memory is the primary one that
>> comes to mind.
>
> How would you propose making it modular?
>
> -- Dave
>


Well it seems to me that the initial focus here is in live migration  
of traditional enterprise applications, e.g. databases, app-servers,  
etc. I think this is the right focus given how much utility the  
general enterprise is finding in capabilities like VMotion. Providing  
this mobility to applications without the overhead of traditional VM's  
would be very valuable.

On the other hand I've been primarily focused in checkpointing large- 
scale MPI jobs to provide fault tolerance, and that use-case is  
somewhat different then the live-migration one. These checkpoints have  
huge RAM footprints (in-core checkpointing is not an option), require  
coordination across large numbers of servers, some number of open  
files  on an enormous parallel filesystem, and some scratch files open  
on the local disk/ramdisk. They generally have very simple process  
trees with one process per core, or one process with a thread for each  
core.

To support these kinds of jobs, one would ideally instruct the  
Container checkpointer to ignore network resources, dynamically  
allocated private memory, and the contents of open files. You'd be  
relying on the Container checkpointer to recreate processes, open file  
descriptors, threads, thread synchronization primitives, IPC  
mechanisms (including shm).

As far as the mechanism is concerned, I'd defer to the more  
experienced kernel developers here. I assume that passing a bitmask of  
flags as an argument into the checkpoint syscall would be frowned  
upon, and anyways redundant, as its unlikely that the mask would  
change within a container from checkpoint to checkpoint. If each  
container is going to have a CGroup filesystem directory, then we  
could have a file(s) along the lines of /proc/sys/kernel/ 
randomize_va_space that turn features off for that Container. The  
default settings after Container creation would be a complete in- 
kernel checkpoint/migration.

thanks,
Joe

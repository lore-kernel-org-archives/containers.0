From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: C/R minisummit notes
Date: Wed, 23 Jul 2008 17:38:20 -0400
Message-ID: <4887A4CC.5070009@cs.columbia.edu>
References: <4887163F.5090801@fr.ibm.com> <20080723211818.GA10295@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080723211818.GA10295-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
>>   * What are the problems that the linux community can solve with the 
>> checkpoint/restart ?
>>
>> 	Eric Biederman reminds at the previous OLS nobody complained about the 
>> checkpoint/restart
>>
>> 	Pavel Emylianov : The startup of Oracle takes some minutes, if we 
>> checkpoint just after the startup, Oracle can be restarted from this 
>> point later and provide fast startup
>>
>> 	Oren Laaden : Time travel, we can do monotonic snapshot and go back on 
>> one of this snaphost.
>>
>> 	Eric Biedreman : Priority running, checkpoint/kill an application and 
>> run another application with a bigger priority
>>
>> 	Denis Lunev : Task migration, move application on one host to another host
>>
>> 	Daniel Lezcano : SSI (task migration)
>>
>>   * Preparing the kernel internals
>>
>> 	OL : Can we implement a kernel module and move CR functionality into 
>> the kernel itself later ?
>>
>> 	EB : Better to add a little CR functionnality into the kernel itself 
>> and add more after.
>>
>> 	DLu : Problem with kernel version
>>
>> 	OL : Compatibility with intermediate kernel version should be possible 
>> with userspace conversion tools
>>
>> 	DLu : Non sequential file for checkpoint statefile is a challenge
>>
>> 	OL : yes, but possible and useful for compression/encryption
>>
>> 	We showed that there are five steps to realize a checkpoint:
>>
>> 	1 - Pre-dump
> 
> I'd just add here that the pre-dump is where you might start writing
> memory to disk, trying to get disk and memory closer and closer to
> being the same until, at some point, you decide they are close enough
> that you can go on to step two, and attempt the freeze+dump+migrate/kill
> with minimal downtime.
> 
> Coming into the discussion my primary concern had been that doing a
> sys_checkpoint() system call would be tough to augment to provide this
> kind of incremental checkpoint, but this breakdown is great for that.
> 
>> 	2 - Freeze
>> 	3 - Dump
>> 	4 - Resume/kill
>> 	5 - Post-dump
>>
>> 	At this point we state we want create a proof of concept and 
>> checkpoint/restart the simplest application.
> 
> By which we mean, start with a piece of step 3 (and maybe a bit of
> step 4).

step 4 is also part of the freezer -- it's the unfreeze operation
(or force a SIGKILL to all processes in the container).

> 
> Step 2 was pretty widely accepted to be the freezer subsystem, but
> noone seemed to be sure quite what the status of that was.
> 
> Matt, can you remind us how the freezer cgroup is doing?
> 
>> 	We will add iteratively more and more kernel resources.
>>
>> 	Process hierarchy created from kernel or userspace ?
>>
>> 	OL : Seems better to send a chunk of data to kernel and that restores 
>> the processes hierarchy
>> 	PE : Agreed
>> 	OL : We should be able to checkpoint from inside the container, keep 
>> that in mind for later.
>> 	
>> 	=> we need a syscall or a ioctl
>>
>> 	The first items to address before implementing the Checkpoint are:
>> 	1 - Make a container object (the context)
>> 	2 - Freeze the container (extend cgroup freezer ?)
>> 	3 - syscall | ioctl
>>
>> 	First step:
>> 		* simplest application : A single process, without any file, no 
>> checkpoint of text file (same file system for restart), no signals, no 
>> syscall in the application, no ipc/no msgq, no network
>>
>> 	Second step:
>> 		* multiple processes + zombie state
>>
>> 	Third step:
>> 		* files, pipe, signals, socketpair ?
>>
>> 	This proof of concept must came with a documentation describing what is 
>> supported, what is not supported and what we plan to do.
> 
> And there was talk of making sure that if you attempt to checkpoint an
> app using unsupported resources, we return -EAGAIN.  There had been
> murmurings about giving more meaningful feedback, but I have no idea
> what that would look like.

yes. some of it is mentioned in the notes that I put in the wiki.


> 
> -serge
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

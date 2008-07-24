From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: C/R minisummit notes
Date: Wed, 23 Jul 2008 22:26:16 -0500
Message-ID: <20080724032616.GB9839@us.ibm.com>
References: <4887163F.5090801@fr.ibm.com> <20080723211818.GA10295@us.ibm.com>
	<4887A4CC.5070009@cs.columbia.edu>
	<20080724014122.GA23105@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080724014122.GA23105-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | 
> | 
> | Serge E. Hallyn wrote:
> | > Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> | >>   * What are the problems that the linux community can solve with the 
> | >> checkpoint/restart ?
> | >>
> | >> 	Eric Biederman reminds at the previous OLS nobody complained about the 
> | >> checkpoint/restart
> | >>
> | >> 	Pavel Emylianov : The startup of Oracle takes some minutes, if we 
> | >> checkpoint just after the startup, Oracle can be restarted from this 
> | >> point later and provide fast startup
> | >>
> | >> 	Oren Laaden : Time travel, we can do monotonic snapshot and go back on 
> | >> one of this snaphost.
> | >>
> | >> 	Eric Biedreman : Priority running, checkpoint/kill an application and 
> | >> run another application with a bigger priority
> | >>
> | >> 	Denis Lunev : Task migration, move application on one host to another host
> | >>
> | >> 	Daniel Lezcano : SSI (task migration)
> | >>
> | >>   * Preparing the kernel internals
> | >>
> | >> 	OL : Can we implement a kernel module and move CR functionality into 
> | >> the kernel itself later ?
> | >>
> | >> 	EB : Better to add a little CR functionnality into the kernel itself 
> | >> and add more after.
> | >>
> | >> 	DLu : Problem with kernel version
> | >>
> | >> 	OL : Compatibility with intermediate kernel version should be possible 
> | >> with userspace conversion tools
> | >>
> | >> 	DLu : Non sequential file for checkpoint statefile is a challenge
> | >>
> | >> 	OL : yes, but possible and useful for compression/encryption
> | >>
> | >> 	We showed that there are five steps to realize a checkpoint:
> | >>
> | >> 	1 - Pre-dump
> | > 
> | > I'd just add here that the pre-dump is where you might start writing
> | > memory to disk, trying to get disk and memory closer and closer to
> | > being the same until, at some point, you decide they are close enough
> | > that you can go on to step two, and attempt the freeze+dump+migrate/kill
> | > with minimal downtime.
> | > 
> | > Coming into the discussion my primary concern had been that doing a
> | > sys_checkpoint() system call would be tough to augment to provide this
> | > kind of incremental checkpoint, but this breakdown is great for that.
> | > 
> | >> 	2 - Freeze
> | >> 	3 - Dump
> | >> 	4 - Resume/kill
> | >> 	5 - Post-dump
> | >>
> | >> 	At this point we state we want create a proof of concept and 
> | >> checkpoint/restart the simplest application.
> | > 
> | > By which we mean, start with a piece of step 3 (and maybe a bit of
> | > step 4).
> | 
> | step 4 is also part of the freezer -- it's the unfreeze operation
> | (or force a SIGKILL to all processes in the container).
> 
> Are steps 1-5 considered part of the sys_checkpoint() system call and
> if successful sys_checkpoint() returns after step 5 ?
> 
> If so, like Serge points out, it would be harder to optimize for
> incremental checkpoints (as each sys_checkpoint() would be independent) ?

No no, the idea (IIUC) is that if you want to do a very short-downtime
migrate, you stay in step 1 for a long time, writing the container
memory to disk, checking how different the disk img is from the memory
image, updating the version on disk, checking again, etc.  Then when
you decide that the disk and memory are very close together, you
quickly do steps 2-4, where 4 in this case is kill.  In the meantime
you would have been loading the disk data into memory ahead of time
at the new machine, so you can also quickly complete the restart.

So 3, 'Dump', in this case really becomes "dump the metadata and any
more changes that have happened."  Presumably, if when you get to 3,
you find that there was suddenly a lot of activity and there is too
much data to write quickly, you bail on the migrate and step 4 is
a resume rather than kill.  Then you start again at step 1.

At least that was my understanding.

> But may not be something to worry about for POC.

From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: C/R minisummit notes
Date: Wed, 23 Jul 2008 13:30:07 +0200
Message-ID: <4887163F.5090801@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


  * What are the problems that the linux community can solve with the 
checkpoint/restart ?

	Eric Biederman reminds at the previous OLS nobody complained about the 
checkpoint/restart

	Pavel Emylianov : The startup of Oracle takes some minutes, if we 
checkpoint just after the startup, Oracle can be restarted from this 
point later and provide fast startup

	Oren Laaden : Time travel, we can do monotonic snapshot and go back on 
one of this snaphost.

	Eric Biedreman : Priority running, checkpoint/kill an application and 
run another application with a bigger priority

	Denis Lunev : Task migration, move application on one host to another host

	Daniel Lezcano : SSI (task migration)

  * Preparing the kernel internals

	OL : Can we implement a kernel module and move CR functionality into 
the kernel itself later ?

	EB : Better to add a little CR functionnality into the kernel itself 
and add more after.

	DLu : Problem with kernel version

	OL : Compatibility with intermediate kernel version should be possible 
with userspace conversion tools

	DLu : Non sequential file for checkpoint statefile is a challenge

	OL : yes, but possible and useful for compression/encryption

	We showed that there are five steps to realize a checkpoint:

	1 - Pre-dump
	2 - Freeze
	3 - Dump
	4 - Resume/kill
	5 - Post-dump

	At this point we state we want create a proof of concept and 
checkpoint/restart the simplest application.

	We will add iteratively more and more kernel resources.

	Process hierarchy created from kernel or userspace ?

	OL : Seems better to send a chunk of data to kernel and that restores 
the processes hierarchy
	PE : Agreed
	OL : We should be able to checkpoint from inside the container, keep 
that in mind for later.
	
	=> we need a syscall or a ioctl

	The first items to address before implementing the Checkpoint are:
	1 - Make a container object (the context)
	2 - Freeze the container (extend cgroup freezer ?)
	3 - syscall | ioctl

	First step:
		* simplest application : A single process, without any file, no 
checkpoint of text file (same file system for restart), no signals, no 
syscall in the application, no ipc/no msgq, no network

	Second step:
		* multiple processes + zombie state

	Third step:
		* files, pipe, signals, socketpair ?

	This proof of concept must came with a documentation describing what is 
supported, what is not supported and what we plan to do.

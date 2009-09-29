From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [LPC] Notes from Checkpoint/Restart BOF
Date: Mon, 28 Sep 2009 17:17:54 -0700
Message-ID: <20090929001754.GA19933@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, yinghan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, sqazi-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Notes from Checkpoint/Restart BOF at Linux Plumbers Conference, Sep 24, 2009.

(I am missing some details and couple of names. They said they were on
Containers mailing list though. If you have any other topics that we
discussed or have any details, please add to this mail).

---

Attendees:
	Oren Laadan, Joeseph Ruscio, <One more person> (Librato)
	Pavel Emelyanov, <One more person ?> (OpenVZ)
	Ying Han, Salman Qazi (Google)
	Dan Smith, Matt Helsley, Sukadev Bhattiprolu (IBM)

1. Pavel: A few months ago there were discussions about making a "dry-run"
   to see if checkpoint of an application will succeed. What is the
   current status of that ?

	The answer was there is no dry-run - user should just try the
	actual C/R. If application is using an uncheckpointable resource
	the C/R will fail cleanly without side-effects. 
	The dry-run may not mean anything unless we freeze the application
	during the check and leave it frozen until the checkpoint is done.
	IOW, the dry-run does not guarantee that application is checkpointable
	unless the application is frozen.

2. Pavel: Alexey Dobriyan had earlier submitted some code for leak-detection. Do
   we still have that ?

   	The answer was that most of the code was used and we also added reverse
	detection.

3. Do we have a config-option to make a process checkpointable.

	<Missed the context of this question> We have CONFIG_CHECKPOINT.

4 Checkpointing network connections:

	We quickly reviewed the status (AF_UNIX done, AF_INET done in a
	prototype and needs to be forward ported). Checkpoint of one-end
	of a network connection can cause the connection to be reset.

5. Briefly discussed distinction between Live migration and static migration

6. Do we need a pre-check during restart to ensure that the application can
   be restarted ? Eg: if the application used a specific math co-processor
   or futex at checkpoint and that resource is not available at restart,
   the restart may encounter some undefined behavior. Should we encode the
   hardware/OS capabilities in the checkpoint image and check these
   capabilities during restart (before actual restart). Reason for this
   check being the restart may not fail cleanly if the resource is missing.

   	Conclusion was that there could be too many such capabilities that
	we would have to track and even so there may be some unexpected
	difference between checkpoint machine and restart machine.

	For now, let the restart fail and/or deal with in user-space.

7. Discussed briefly about clone2() aka clone_with_pids().

	Everyone seemed to agree that restoring process-tree even in user-space
	will work and can be used.

8. Oren: Error reporting during restart

	We currently fail the system call with an error code and if we ant
	more information on the failure, we have to add debug messages to
	the code. We discussed couple of options for error reporting on restart:
		- log detailed message(s) to console (risk wrapping dmesg buf)
		- pass an extra-buffer to the system call and have kernel
		  fill-in more detailed error message (would need two new
		  parameters, one pointer to the buf, one size of the buf).

		- Pass-in an extra 'log_fd' parameter to system call and have
		kernel write detailed messags to that log_fd (unless log_fd
		is -1). This seemed more flexible than the other two.

		We agreed that the format of the log messages can be free-format
		and that there is no guarantee that the format of the log
		messages will not change.

		But it was not clear (at least to me) if the log file should
		contain all log messages relating to the C/R or just the
		last (few) error messages.

9. Any application to summarize the checkpoint ?

	We have a 'ckptinfo' that could summarize the contents of a checkpoint.

10. Ying Han: Is there a performance difference between the original instance
    of the application and the restarted instance ? (Eg: on NUMA if application
    was on one node at checkpoint and after restart, ended up on another node).

    	Not sure if there was a conclusion to this point.

11. Discussed that devices like tty, /dev/rtc etc must be virtualized before
    we can checkpoint them.

12. Oren: Checkpointing/Restoring mount namespaces

	Bind mounts are restored in container.

	NFS: at least on OpenVZ, since network is frozen, reopening files over
	NFS is not possible until restart is complete. OpenVZ creates fake
	dentries to allow the open to proceed.

	Loopback devices - cannot open them in a container since they can
		lockup system with huge memory footprint ??

	We should disable shared-mount propogation at least for now.

13. Oren: cradvise()

	Use a single system call to optimize the checkpoint/restart ?
	Eg: If an fd refers to /dev/tty1 in the checkpoint-image and that tty
	is not available on restart, user-space could open another tty and
	teach the kernel to use a different tty, /dev/tty2, during
	restart. Another example is if an application has several megs of
	"scratch" memory  that does not need to checkpointed, they could
	use 'cradvise') system call to optimize the checkpoint or restart.

	The conclusion was it would be hard to get acceptance from community,
	for a new variant of ioctl/fcntl call. So, we should instead try to
	add the necessary features to existing system calls like fcntl(),
	shmctl() or madvise().

14. Oren: Unlinked files/directories

	May need to copy the contents of the deleted file to the
	checkpoint image (only on ext4?). Create a fake hard link to the
	file so the file still exists in the filesystem snapshot and remove
	the link during restart.

	There is a good paper discussing snapshot/restore of unlinked files
	on Xen. The same concept could be used in C/R too ?

	(If you have links to the paper, please add)

15. Network namespaces

	Restore namespaces in user-space, restore sockets in-kernel.

	Cannot create devices in user-space unless we know the index for
	the network device ?

	(Missed details on this discussion)

16. Time

	Will need some policies on restart like:
		- use absolute time or relative time
		- do new children inherit the policy ?
		- do we gradually adjust from relative to absolute time ?

	If not cradvise(), maybe timectl() :-p

17. VDSO

	(Missed details on this discussion)

18. Async I/O

	Getting a lockdep report during checkpoint ?
	OpenVZ flushes I/O, waits for pending I/O and then retries checkpoint
	We may need to the do the same for mmap I/O ?

19. Checkpoint data structures:

	- Try to keep extensions to existing data structures minimal
	- If necessary, add to end of data structures
	- But do not get locked down to an ABI at this point. i.e.  even after
	  entering mainline, format of checkpoint image may change for a while
	  before stabilizing.

20. Test suite:

	OpenVZ has some test cases that has various applications go to specific
	states and wait for a checkpoint. After that and after restart they
	check that nothing has changed unexpectedly.

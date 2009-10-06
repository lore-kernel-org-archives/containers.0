From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: 2009 kernel summit preparation for 'containers end-game' discussion
Date: Tue, 6 Oct 2009 10:56:37 -0500
Message-ID: <20091006155637.GA14761@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, cgroup-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Balbir Singh <balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Sukadev
List-Id: containers.vger.kernel.org

Hi,

the kernel summit is rapidly approaching. One of the agenda
items is 'the containers end-game and how do we get there.'
As of now I don't yet know who will be there to represent the
containers community in that discussion.  I hope there is
someone planning on that?  In the hopes that there is, here is
a summary of the info I gathered in June, in case that is
helpful.  If it doesn't look like anyone will be attending
ksummit representing containers, then I'll send the final
version of this info to the ksummit mailing list so that someone
can stand in.

1. There will be an IO controller minisummit before KS.  I
trust someone (Balbir?) will be sending meeting notes to
the cgroup list, so that highlights can be mentioned at KS?

2. There was a checkpoint/restart BOF plus talk at plumber's.
Notes on the BOF are here:
https://lists.linux-foundation.org/pipermail/containers/2009-September/020915.html

3. There was an OOM notification talk or BOF at plumber's.
Dave or Balbir, are there any notes about that meeting?

4. The actual title of the KS discussion is 'containers end-game'.
The containers-specific info I gathered in June was mainly about
additional resources which we might containerize.  I expect that
will be useful in helping the KS community decide how far down
the containerization path they are willing to go - i.e. whether
we want to call what we have good enough and say you must use kvm
for anything more, whether we want to be able to provide all the
features of a full VM with containers, or something in between,
say targetting specific uses (perhaps only expand on cooperative
resource management containers).  With that in mind, here are
some items that were mentioned in June as candidates for
more containerization work

	1. Cpu hard limits, memory soft limits (Balbir)
	2. Large pages, mlock, shared page accounting (Balbir)
	3. Oom notification (Balbir - was anything decided on this
		at plumber's?)
	4. There is agreement on getting rid of the ns cgroup,
		provided that:
		a. user namespaces can provide container confinement
		guarantees
		b. a compatibility flag is created to clone parent
		cgroup when creating a new cgroup (Paul and Daniel)
	5. Poweroff/reboot handling in containers (Daniel)
	6. Full user namespaces to segragate uids in different
		containers and confine root users in containers, i.e.
		with respect to file systems like cgroupfs.
	7. Checkpoint/restart (c/r) will want time virtualization (Daniel)
	8. C/r will want inode virtualization (Daniel)
	9. Sunrpc containerization (required to allow multiple
		containers separate NFS client access to the same server)
	10. Sysfs tagging, support for physical netifs to migrate
		network namespaces, and /sys/class/net virtualization

Again the point of this list isn't to ask for discussion about
whether or how to implement each at this KS, but rather to give
an idea of how much work is left to do.  Though let the discussion
lead where it may of course.

I don't have it here, but maybe it would also be useful to
have a list ready of things we can do today with containerization?
Both with upstream, and with under-development patchsets.

I also hope that someone will take notes on the ksummit
discussion to send to the containers and cgroup lists.
I expect there will be a good LWN writeup, but a more
containers-focused set of notes will probably be useful
too.

thanks,
-serge

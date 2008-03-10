From: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Subject: [RFC][PATCH 0/4] Object creation with a specified id
Date: Mon, 10 Mar 2008 14:50:54 +0100
Message-ID: <20080310135054.312992000@bull.net>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


A couple of weeks ago, a discussion has started after Pierre's proposal for
a new syscall to change an ipc id (see thread
http://lkml.org/lkml/2008/1/29/209).


Oren's suggestion was to force an object's id during its creation, rather
than 1. create it, 2. change its id.

So here is an implementation of what Oren has suggested.

2 new files are defined under /proc/self:
  . next_ipcid --> next id to use for ipc object creation
  . next_pids --> next upid nr(s) to use for next task to be forked
                  (see patch #2 for more details).

When one of these files (or both of them) is filled, a structure pointed to
by the calling task struct is filled with these ids.

Then, when the object is created, the id(s) present in that structure are
used, instead of the default ones.

The patches are against 2.6.25-rc3-mm1, in the following order:

[PATCH 1/4] adds the procfs facility for next ipc to be created.
[PATCH 2/4] adds the procfs facility for next task to be forked.
[PATCH 3/4] makes use of the specified id (if any) to allocate the new IPC
            object (changes the ipc_addid() path).
[PATCH 4/4] uses the specified id(s) (if any) to set the upid nr(s) for a newly
            allocated process (changes the alloc_pid()/alloc_pidmap() paths).

Any comment and/or suggestions are welcome.

Cc-ing Pavel and Sukadev, since they are the pid namespace authors.

Regards,
Nadia

--

--

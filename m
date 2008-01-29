From: pierre.peiffer-6ktuUTfB/bM@public.gmane.org
Subject: [PATCH 2.6.24-rc8-mm1 00/15] IPC: code rewrite + new functionalities
Date: Tue, 29 Jan 2008 17:02:29 +0100
Message-ID: <20080129160229.612172683__35649.1475402892$1201623543$gmane$org@bull.net>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

	Here is a patchset about the IPC, which proposes to consolidate some
part of the existing code and to add some functionalities.

* Patches 1 to 8 don't change the existing behavior, but propose to rewrite
some parts of the existing code. In fact, the three kinds of IPC (semaphores,
message queues and shared memory) have some common commands (IPC_SET, IPC_RMID,
etc...) but they are mainly handled in three different ways. These patches
propose to consolidate this, by handling these commands the same way and try
to use, as much as possible, some common code. This should increase
readability and maintainability of the code, making them probably good
candidate for the -mm tree, I think.

* Patches 9 to 15 propose to add some functionalities, and thus are
submitted here for RFC, about both the interest and their implementation.
These functionalities are:
    - Two new control-commands:
	. IPC_SETID: to change an IPC's id.
	. IPC_SETALL: behaves as IPC_SET, except that it also sets all time
	  and pid values)
    - add a /proc/<pid>/semundo file to read and write the undo values of
some semaphores for a given process.

	As the namespaces and the "containers" are being integrated in the
kernel, these functionalities may be a first step to implement  the
checkpoint/restart of an application: in fact the existing API does not allow
to specify or to change an ID when creating an IPC, when restarting an
application, and the times/pids values of each IPCs are also altered. May be
someone may find another interest about this ?

So again, comments are welcome.

Thanks.

-- 
Pierre

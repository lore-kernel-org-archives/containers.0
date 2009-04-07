From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 02/29] Checkpoint/restart: initial
	documentation
Date: Mon, 6 Apr 2009 20:22:53 -0700
Message-ID: <20090407032253.GA12316@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-3-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-3-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


Just a nit:

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:

| From 6f5483b085b1fb675a8445c65ddbeb7b38187865 Mon Sep 17 00:00:00 2001
| From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Date: Mon, 30 Mar 2009 10:45:53 -0400
| Subject: [PATCH 02/29] Checkpoint/restart: initial documentation
| 
| Covers application checkpoint/restart, overall design, interfaces,
| usage, shared objects, and and checkpoint image format.
| 
| Changelog[v14]:
|   - Discard the 'h.parent' field
| 
| Changelog[v8]:
|   - Split into multiple files in Documentation/checkpoint/...
|   - Extend documentation, fix typos and comments from feedback
| 
| Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| ---
|  Documentation/checkpoint/ckpt.c        |   32 ++++++
|  Documentation/checkpoint/internals.txt |  127 +++++++++++++++++++++++
|  Documentation/checkpoint/readme.txt    |  105 +++++++++++++++++++
|  Documentation/checkpoint/rstr.c        |   20 ++++
|  Documentation/checkpoint/security.txt  |   38 +++++++
|  Documentation/checkpoint/self.c        |   57 +++++++++++
|  Documentation/checkpoint/test.c        |   48 +++++++++
|  Documentation/checkpoint/usage.txt     |  171 ++++++++++++++++++++++++++++++++
|  8 files changed, 598 insertions(+), 0 deletions(-)
|  create mode 100644 Documentation/checkpoint/ckpt.c
|  create mode 100644 Documentation/checkpoint/internals.txt
|  create mode 100644 Documentation/checkpoint/readme.txt
|  create mode 100644 Documentation/checkpoint/rstr.c
|  create mode 100644 Documentation/checkpoint/security.txt
|  create mode 100644 Documentation/checkpoint/self.c
|  create mode 100644 Documentation/checkpoint/test.c
|  create mode 100644 Documentation/checkpoint/usage.txt
| 
| diff --git a/Documentation/checkpoint/ckpt.c b/Documentation/checkpoint/ckpt.c
| new file mode 100644
| index 0000000..094408c
| --- /dev/null
| +++ b/Documentation/checkpoint/ckpt.c
| @@ -0,0 +1,32 @@
| +#include <stdio.h>
| +#include <stdlib.h>
| +#include <errno.h>
| +#include <unistd.h>
| +#include <sys/syscall.h>
| +
| +int main(int argc, char *argv[])
| +{
| +	pid_t pid;
| +	int ret;
| +
| +	if (argc != 2) {
| +		printf("usage: ckpt PID\n");
| +		exit(1);
| +	}
| +
| +	pid = atoi(argv[1]);
| +	if (pid <= 0) {
| +		printf("invalid pid\n");
| +		exit(1);
| +	}
| +
| +	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
| +
| +	if (ret < 0)
| +		perror("checkpoint");
| +	else
| +		printf("checkpoint id %d\n", ret);
| +
| +	return (ret > 0 ? 0 : 1);
| +}
| +
| diff --git a/Documentation/checkpoint/internals.txt b/Documentation/checkpoint/internals.txt
| new file mode 100644
| index 0000000..c741b6c
| --- /dev/null
| +++ b/Documentation/checkpoint/internals.txt
| @@ -0,0 +1,127 @@
| +
| +	===== Internals of Checkpoint-Restart =====
| +
| +
| +(1) Order of state dump
| +
| +The order of operations, both save and restore, is as follows:
| +
| +* Header section: header, container information, etc.
| +
| +* Global section: [TBD] global resources such as IPC, UTS, etc.
| +
| +* Process forest: [TBD] tasks and their relationships
| +
| +* Per task data (for each task):
| +  -> task state: elements of task_struct
| +  -> thread state: elements of thread_struct and thread_info
| +  -> CPU state: registers etc, including FPU
| +  -> memory state: memory address space layout and contents
| +  -> filesystem state: [TBD] filesystem namespace state, chroot, cwd, etc
| +  -> files state: open file descriptors and their state
| +  -> signals state: [TBD] pending signals and signal handling state
| +  -> credentials state: [TBD] user and group state, statistics
| +
| +
| +(2) Checkpoint image format
| +
| +The checkpoint image format is composed of records consisting of a
| +pre-header that identifies its contents, followed by a payload. (The
| +idea here is to enable parallel checkpointing in the future in which
| +multiple threads interleave data from multiple processes into a single
| +stream).
| +
| +The pre-header is defined by "struct cr_hdr" as follows:
| +
| +struct cr_hdr {
| +	__s16 type;
| +	__s16 len;
| +};
| +
| +'type' identifies the type of the payload, 'len' tells its length in
| +bytes, and 'parent' identifies the owner object instance.

Nit: Remove reference to 'parent'.

Suka

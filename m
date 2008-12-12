From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 12199] New: /proc/1/exe entry of PID
	namespace init process links to wrong executable
Date: Thu, 11 Dec 2008 17:42:20 -0800
Message-ID: <20081212014219.GA15162@us.ibm.com>
References: <bug-12199-10286@http.bugzilla.kernel.org/>
	<20081211091430.ea3d434d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nFreZHaLTZJo0R7j"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081211091430.ea3d434d.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Andrew Morton [akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org] wrote:
| 
| (switched to email.  Please respond via emailed reply-to-all, not via the
| bugzilla web interface).
| 
| On Thu, 11 Dec 2008 08:16:55 -0800 (PST) bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
| 
| > http://bugzilla.kernel.org/show_bug.cgi?id=12199
| > 
| >            Summary: /proc/1/exe entry of PID namespace init process links to
| >                     wrong executable
| >            Product: Process Management
| >            Version: 2.5
| >      KernelVersion: 2.6.27.8
| >           Platform: All
| >         OS/Version: Linux
| >               Tree: Mainline
| >             Status: NEW
| >           Severity: low
| >           Priority: P1
| >          Component: Other
| >         AssignedTo: process_other-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
| >         ReportedBy: robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
| > 
| > 
| > Latest working kernel version:
| > 
| > None known.
| > 
| > Earliest failing kernel version:
| > 
| > 2.6.25.4, 2.6.27.4 and 2.6.27.8 show this behaviour, but I assume that it
| > exists since 2.6.24 with the introduction of PID namespaces.

Hmm. I am able to repro the behavior with attached test case and with
CLONE_NEWPID removed. Ran this in a chroot shell and it shows complete
path. I tried on Ubuntu 8.04 (2.6.22-15, which has no pid namespace
support).

	$ mount /dev/sda3 /tmp/target
	$ chroot /tmp/target
	$ ./pid_namespace_chroot2
	/proc/self/exe is /tmp/target/tmp/pid_namespace_chroot2

set_mm_exe_file() call from flush_old_exec() sets 'mm->exe_file' to
'linux_bprm.file' and proc_exe_link() picks it up from there. 

Could this be related how linux_bprm.file is populated after chroot ?
I have not traced that yet.

Sukadev

--nFreZHaLTZJo0R7j
Content-Type: text/x-csrc; charset=us-ascii
Content-Description: pid_namespace_chroot2.c
Content-Disposition: attachment; filename="pid_namespace_chroot2.c"

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

#define CLONE_NEWNS     0x00020000
#define CLONE_NEWPID    0x20000000

/** Compile with "gcc -o pid_namespace_chroot2 pid_namespace_chroot2.c" */

int do_child(void)
{
	int status;
	char buf[256];

	if (mount("none", "/proc", "proc", 0, NULL)) {
		perror("mount");
		return 1;
	}

	if (readlink("/proc/self/exe", buf, sizeof(buf)) < 0) {
		perror("READLINK");
		return 1;
	}
	printf("/proc/self/exe is %s\n", buf);

	if (umount("/proc")) {
		perror("umount");
		return 1;
	}


	return 0;
}

int main(void)
{
	int status, pid;
	void *stack = malloc(getpagesize());

	if (!stack) {
		perror("malloc");
		return 1;
	}

	pid = clone(do_child, stack + getpagesize(), CLONE_NEWNS, NULL);
	if (pid == -1) {
		perror("clone");
		return 1;
	}

	if (waitpid(pid, &status, __WALL) < 0) {
		perror("waitpid");
		return 1;
	}

	return 0;
}

--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--nFreZHaLTZJo0R7j--

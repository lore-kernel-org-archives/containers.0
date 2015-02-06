From: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v10 2/2] docs: add missing and new /proc/PID/status file
	entries, fix typos
Date: Fri, 6 Feb 2015 18:45:50 +0800
Message-ID: <1423219550-4385-3-git-send-email-chenhanxiao__3320.82346217266$1423219562$gmane$org@cn.fujitsu.com>
References: <1423219550-4385-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1423219550-4385-1-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

From: Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

docs: add missing and new /proc/PID/status file entries, fix typos

Signed-off-by: Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 Documentation/filesystems/proc.txt | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index aae9dd1..457cebd 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -197,12 +197,12 @@ contains details information about the process itself.  Its fields are
 explained in Table 1-4.
 
 (for SMP CONFIG users)
-For making accounting scalable, RSS related information are handled in
-asynchronous manner and the vaule may not be very precise. To see a precise
+For making accounting scalable, RSS related information are handled in an
+asynchronous manner and the value may not be very precise. To see a precise
 snapshot of a moment, you can see /proc/<pid>/smaps file and scan page table.
 It's slow but very precise.
 
-Table 1-2: Contents of the status files (as of 2.6.30-rc7)
+Table 1-2: Contents of the status files (as of 3.20.0)
 ..............................................................................
  Field                       Content
  Name                        filename of the executable
@@ -210,6 +210,7 @@ Table 1-2: Contents of the status files (as of 2.6.30-rc7)
                              in an uninterruptible wait, Z is zombie,
 			     T is traced or stopped)
  Tgid                        thread group ID
+ Ngid                        NUMA group ID (0 if none)
  Pid                         process id
  PPid                        process id of the parent process
  TracerPid                   PID of process tracing this process (0 if not)
@@ -217,6 +218,10 @@ Table 1-2: Contents of the status files (as of 2.6.30-rc7)
  Gid                         Real, effective, saved set, and  file system GIDs
  FDSize                      number of file descriptor slots currently allocated
  Groups                      supplementary group list
+ NStgid                      descendant namespace thread group ID hierarchy
+ NSpid                       descendant namespace process ID hierarchy
+ NSpgid                      descendant namespace process group ID hierarchy
+ NSsid                       descendant namespace session ID hierarchy
  VmPeak                      peak virtual memory size
  VmSize                      total program size
  VmLck                       locked memory size
-- 
2.1.0

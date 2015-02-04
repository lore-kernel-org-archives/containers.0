From: Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [resend][PATCH v9 2/3] /proc/PID/status: show all sets of pid
	according to ns
Date: Tue, 3 Feb 2015 20:12:08 -0500 (EST)
Message-ID: <175563041.6778432.1423012328350.JavaMail.zimbra@redhat.com>
References: <55349719.6775592.1423011445985.JavaMail.zimbra@redhat.com>
Reply-To: Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <55349719.6775592.1423011445985.JavaMail.zimbra-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Chen, Eric,

Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> writes:
> Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> > If some issues occurred inside a container guest, host user
> > could not know which process is in trouble just by guest pid:
> > [...]
> > Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > Tested-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >
> > Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> At a quick review and read through this looks good.  Once I finish
> clearing the security bug fixes from my tree I will see about picking
> this up.

I recently came across a need for this patch so I just wanted to
say thanks and since I've used it a fair bit feel free to add:

Tested-by: Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

One small tweak you could make is to drop the extra whitespace
from those new seq_printf calls - "\t%d " has a trailing space
that isn't needed.

Also there's proc status docs below Documentation/ that should be
updated for these changes.  They are slightly out-of-date already
and there's a few typos in the vicinity - something like this may
do the trick though ... ?  (will need to be updated at merge time
with the correct kernel version)


docs: add missing and new /proc/PID/status file entries, fix typos

Signed-off-by: Nathan Scott <nathans-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

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

From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the userspace
Date: Fri, 15 Jul 2011 17:45:10 +0400
Message-ID: <4E204466.8010204@parallels.com>
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
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi guys!

There have already been made many attempts to have the checkpoint/restore functionality
in Linux, but as far as I can see there's still no final solutions that suits most of
the interested people. The main concern about the previous approaches as I see it was
about - all that stuff was supposed to sit in the kernel thus creating various problems.

I'd like to bring this subject back again proposing the way of how to implement c/r
mostly in the userspace with the reasonable help of a kernel.


That said, I propose to start with very basic set of objects to c/r that can work with

* x86_64 tasks (subtree) which includes
   - registers
   - TLS
   - memory of all kinds (file and anon both shared and private)
* open regular files
* pipes (with data in it)

Core idea:

The core idea of the restore process is to implement the binary handler that can execve-ute
image files recreating the register and the memory state of a task. Restoring the process 
tree and opening files is done completely in the user space, i.e. when restoring the subtree
of processes I first fork all the tasks in respective order, then open required files and 
then call execve() to restore registers and memory.

The checkpointing process is quite simple - all we need about processes can be read from /proc
except for several things - registers and private memory. In current implementation to get 
them I introduce the /proc/<pid>/dump file which produces the file that can be executed by the
described above binfmt. Additionally I introduce the /proc/<pid>/mfd/ dir with info about
mappings. It is populated with symbolc links with names equal to vma->vm_start and pointing to
mapped files (including anon shared which are tmpfs ones). Thus we can open some task's
/proc/<pid>/mfd/<address> link and find out the mapped file inode (to check for sharing) and
if required map one and read the contents of anon shared memory.

Other minor stuff is in patches and mostly tools. The set is for linux-2.6.39. The current
implementation is not yet well tested and has many other defects, but demonstrates the idea. 

What do you think? Does the support from kernel of the proposed type suit us?

Thanks,
Pavel

From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [RFC][PATCH 0/15] Pid namespaces
Date: Thu, 26 Jul 2007 21:22:13 -0700
Message-ID: <20070727042213.GB23584@us.ibm.com>
References: <46A8B37B.6050108@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46A8B37B.6050108-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel,

We seem to have a memory leak. Its new in this patchset (i.e the
following test ran fine on the 2.6.22-rc6-mm1 patchset).

To repro: run "pidns_exec ./mypid" in a tight-loop  - where mypid.c
is:

#include <stdio.h>
#include <unistd.h>

main()
{
        printf("Pid %d, Ppid %d, Pgid %d, Sid %d\n",
                 getpid(), getppid(), getpgid(0), getsid(0));
}

I ran into OOM in about 30 mins. I am still investigating.

BTW, can we include a simple test program like the pidns_exec in this
patch-0 for whoever want to play with pidns ?

Suka

Pavel Emelianov [xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org] wrote:
| (Comment is taken from Sukadev's patchset-v3)
| 
| A pid namespace is a "view" of a particular set of tasks on the system.
| They work in a similar way to filesystem namespaces.  A file (or a process)
| can be accessed in multiple namespaces, but it may have a different name 
| in each.  In a filesystem, this name might be /etc/passwd in one namespace,
| but /chroot/etc/passwd in another.
| 
| For processes, a process may have pid 1234 in one namespace, but be pid 1
| in another. This allows new pid namespaces to have basically arbitrary
| pids, and not have to worry about what pids exist in other namespaces.
| This is essential for checkpoint/restart where a restarted process's pid
| might collide with an existing process on the system's pid.
| 
| In this particular implementation, pid namespaces have a parent-child
| relationship, just like processes.  A process in a pid namespace may see
| all of the processes in the same namespace, as well as all of the processes
| in all of the namespaces which are children of its namespace. Processes may
| not, however, see others which are in their parent's namespace, but not in
| their own.  The same goes for sibling namespaces.
| 
| This set is based on my patches, I sent before, but it includes some 
| comments
| and patches that I received from Sukadev. Sukadev, please, add your 
| Acked-by,
| Signed-off-by or From, to patches you want (everybody is also welcome :) ).
| 
| The set is based on 2.6.23-rc1-mm1, which already has some preparation 
| patches
| for pid namespaces. After the review and fixing all the comments, this set 
| will be benchmarked and sent to Andrew for inclusion in -mm tree.
| 
| Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
| Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

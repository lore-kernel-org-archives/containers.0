From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: pidns memory leak
Date: Fri, 09 Oct 2009 19:08:44 -0700
Message-ID: <m1vdiouhjn.fsf@fess.ebiederm.org>
References: <4AC5F198.2070407@fr.ibm.com> <20091006040526.GA22923@us.ibm.com>
	<4ACAFD6A.3060008@fr.ibm.com> <20091008030828.GA18973@us.ibm.com>
	<4ACD9ECC.90508@fr.ibm.com> <20091009032928.GA2031@us.ibm.com>
	<4ACF381F.9050808@fr.ibm.com> <20091009203809.GA12230@us.ibm.com>
	<m18wfkl2bf.fsf@fess.ebiederm.org> <20091010015859.GB11904@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091010015859.GB11904-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Fri\, 9 Oct 2009 18\:58\:59 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, andrea-Vyt77T80VFVWk0Htik3J/w@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:
> | Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> | 
> | > Andrea,
> | >
> | > We have been running a leak in child pid namespaces and some early debugging
> | > points to the following commit:
> | >
> | >>> 	commit 7766755a2f249e7e0dabc5255a0a3d151ff79821
> | >>> 	Author: Andrea Arcangeli <andrea-l3A5Bk7waGM@public.gmane.org>
> | >>> 	Date:   Mon Feb 4 22:29:21 2008 -0800
> | >>>
> | >
> | > Reverting the commit seems to fix the leak but we need to do some more
> | > analysis (like the lstat() question Daniel has).
> | 
> | Yes.
> | 
> | That entire path is an optimization.  It should not be needed for correct
> | operation.  Although it may be responsible for some false positives.
> | 
> | > However I have a basic question regarding the commit - the log mentions:
> | >
> | > 	> do_exit->release_task->mark_inode_dirty_sync->schedule() (will never
> | > 	> come back to run journal_stop)
> | >
> | > But release_task() calls shrink_dcache_parent() for a _procfs_ dentry. Does
> | > journal_stop() apply to procfs also ?
> | 
> | The problem when the that PF_EXITING check was introduced is that
> | shrink_dcache_parent could shrink dcache entries for other
> | filesystems.  Last I looked that is no longer the case and we can
> | remove that code.
>
> Ok.
>
> | As I recall proc_flush_task_mnt has a few other minor bugs as well that
> | could cause problems.
>
> Can you give me some more details on those bugs ? Reverting the commit
> seems to fix the problem.
>
> | 
> | Ultimately what problems are you seeing?
>
> We are leaking 'struct pid', proc_inode, and 'struct pid_namespace', when
> container-init exits before its descendant processes. i.e when the
> container-init zaps its descendants and waits for them, it calls the
> proc_flush_task_mnt(), but then misses the shrink_dcache_parent() call due
> to the above commit.
>
> So the proc_inode is never deleted and the references to struct pid and
> pid_namespace never go away. Details of the leak are buried in the
> previous mail...

In should be the case that bloating up the dcache so that we get a general
shrink_dcache from the memory reclaim code will free the proc_inode and
the appropriate data structures.  struct pid is supposed to be small and
safe to leak in rare circumstances.

It should be possible to trigger this condition by creating a pid namespace.
cd /proc/<pid>/  (where <pid> is some process in that pid namespace)

Terminating that pid namespace.

But you are still actively using the proc_inode and the struct pid for the
process that has been killed.  Because a process has it as it's current
working directory.

Eric

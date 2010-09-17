From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 8/8] checkpoint/restart of SysV SHM_HUGETLB regions
Date: Fri, 17 Sep 2010 14:03:22 -0500
Message-ID: <1284750203.4109.316.camel@localhost.localdomain>
References: <1284494530-25946-1-git-send-email-ntl@pobox.com>
	<1284494530-25946-9-git-send-email-ntl@pobox.com>
	<4C92B903.20304@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C92B903.20304-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2010-09-16 at 20:40 -0400, Oren Laadan wrote:
> 
> On 09/14/2010 04:02 PM, Nathan Lynch wrote:
> > Large page-backed shm regions require special handling, especially
> > during restart.  The association of a large page with a shm region's
> > inode can occur only in the context of a process causing a fault with
> > the region mapped into its mm.  In order to restore that association,
> > temporarily shmat-attach the restored SHM_HUGETLB region to the
> > restarting process's mm, using the just-restored ipc namespace
> > instead of the current one (the nsproxy switch hasn't occured yet).
> > 
> > Since the temporary shmat of the region during restart causes some of
> > the shm attributes to be updated, re-restore them from the ipc_shm
> > checkpoint header after unmapping.
> 
> Would it work to just move the original call to load_ipc_shm_hdr()
> further down in restore_ipc_shm(), especially since the mutex is
> not needed anymore - that way you don't need to re-restore them ?

load_ipc_shm_hdr indirectly calls the security context restore stuff, so
I'm not sure whether it's okay to change the ordering here.  But perhaps
it would make sense to defer restoring the shm_* fields until after
restoring contents.

Of course, it would be best if we could figure out a way to restore
SHM_HUGETLB contents without artificially attaching segments to the
restoring task's mm.  But so far I haven't been able to do that.

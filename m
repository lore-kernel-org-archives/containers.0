From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Checkpoint/restart (was Re: [PATCH 0/4] - v2 - Object creation
	with a specified id)
Date: Fri, 11 Jul 2008 04:32:58 +0400
Message-ID: <20080711003258.GA23143__9607.32688331536$1215736797$gmane$org@martell.zuzino.mipt.ru>
References: <1208904967.17117.51.camel@nimitz.home.sr71.net>
	<480ED9D5.1010906@parallels.com> <480FE037.2010302@cs.columbia.edu>
	<m1y74a7b4w.fsf@frodo.ebiederm.org>
	<1215709949.9398.15.camel@nimitz>
	<20080710173246.GA1857@us.ibm.com>
	<m163rd1sd5.fsf@frodo.ebiederm.org>
	<1215716794.9398.41.camel@nimitz>
	<m14p6xy27s.fsf@frodo.ebiederm.org>
	<1215719252.9398.53.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1215719252.9398.53.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, nick-dnCCA748QAperShJXdIFYw@public.gmane.org, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 10, 2008 at 12:47:32PM -0700, Dave Hansen wrote:
> On Thu, 2008-07-10 at 12:21 -0700, Eric W. Biederman wrote:
> > > Are we talking about the VMA itself, or the memory backing the VMA?
> > 
> > The memory backing the VMA.  We need to store the page protections
> > that the memory was mapped with as well now that you point it out.  A
> > VMA is not user space visible, which is why we can arbitrarily split
> > and merge VMAs.
> 
> It is visible with /proc/$pid/{maps,smaps,numamaps?}.  That's the only
> efficient way I know of from userspace to figure out where userspace's
> memory is and if it *is* file backed, and what the permissions are.

None of those files exist if PROC_FS is off.

> We also can't truly split them arbitrarily because the memory cost of
> the VMAs themselves might become too heavy (the remap_file_pages()
> problem).
> 
> It gets trickier when things are also private mappings in addition to
> being in a file-backed VMA.  We *do* need to checkpoint those, but only
> the pages to which there was a write.
> 
> There's also the problem of restoring things read-only, but VM_MAYWRITE.
> If there's a high level of (non-COW'd) sharing of these anonymous areas,
> we may not be able to even restore the set of processes unless we can
> replicate the sharing.  We might run out of memory if the sharing isn't
> replicated.

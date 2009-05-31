From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 14/38] Remove struct mm_struct::exe_file et al
Date: Mon, 1 Jun 2009 01:54:27 +0400
Message-ID: <20090531215427.GA29534@x200.localdomain>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090526162415.fb9cefef.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 26, 2009 at 04:24:15PM -0700, Andrew Morton wrote:
> On Tue, 26 May 2009 04:36:18 -0700
> Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > I don't see any mention in the changelog of the point brought up by Ingo:
> > 
> > http://lkml.org/lkml/2009/4/10/105
> 
> Nor of Eric's comments.
> 
> Alexey, pleeeze don't do this.  We (read: I) heavily depend upon patch
> submitters to keep track of outstanding issues and review comments,
> etc.
> 
> If the patch submitter simply blows these things off then it devolves
> to me having to keep track of each patch's issue list as well as the
> patch itself.  My workload goes up by a factor of N and the error rate
> goes up by N^2 :(

grmbh..

"Security" and "holding ->mmap_sem" were answered and dismissed.

You can't do readlink(2) on /proc/*/exe if you can't ptrace task.
So no new possible holes are created.

->mmap_sem was held since /proc/*/exe was added and nobody cared.
And, again, you can't readlink _any_ /proc/*/exe.

Patch simply restores code to year-back state.

I'll send removal and readddition of "struct path" as separate things
next time.


And BTW, there is something unnatural when executable path is attached
to mm_struct(!) not task_struct, so yet another argument to ->exe_file
removal.

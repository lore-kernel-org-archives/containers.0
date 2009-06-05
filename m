From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] exec_path 1/9: introduce ->exec_path and switch
	/proc/*/exe
Date: Fri, 5 Jun 2009 19:41:47 +0400
Message-ID: <20090605154147.GA16766__9821.14720759473$1244216763$gmane$org@x200.localdomain>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
	<20090531215427.GA29534@x200.localdomain>
	<20090531151953.8f8b14b5.akpm@linux-foundation.org>
	<20090603230422.GB853@x200.localdomain>
	<20090605104517.GA11713@infradead.org>
	<alpine.LFD.2.01.0906050808551.6847@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0906050808551.6847-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jun 05, 2009 at 08:10:50AM -0700, Linus Torvalds wrote:
> On Fri, 5 Jun 2009, Christoph Hellwig wrote:
> >
> > On Thu, Jun 04, 2009 at 03:04:22AM +0400, Alexey Dobriyan wrote:
> > > ->exec_path is copied on clone(2) and put at do_exit() time.
> > > 
> > > ->exec_path is going to replace struct mm_struct::exe_file et al
> > > and allows to remove VM_EXECUTABLE flag while keeping readlink("/proc/*/exe")
> > > without loop over all VMAs.
> > 
> > Why don't you leave it in mm_struct?  That'll avoid having to mess with
> > it in clone,

There is no mess in clone:

	+       get_task_exec_path(current, &p->exec_path);

and there is no mess in exit:

	+       set_task_exec_path(tsk, &(struct path){ .mnt = NULL, .dentry = NULL });

> > and given that exec always replaces the whole VM it's a more natural fit anyway.
> 
> Oh, I didn't even notice that, because I just assumed it was in mm_struct 
> already due to the earlier discussion.
> 
> So I concur with Christoph - that field should be in the mm_struct. The 
> executable is a "mapping" issue,

This mapping issue is what created VM_EXECUTABLE/MAP_EXECUTABLE in
the first place, I assume? Never mind it's cheap hack.

> and goes along with task->mm, and should be there, not in task_struct.

Because ->mm can be borrowed to unrelated task and user has to check
for it.

> So it should be copied at fork() time when you do the dup_mm(), not 
> anywhere else.

From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 33/36] Support for share memory address spaces
Date: Thu, 9 Apr 2009 17:52:12 -0500
Message-ID: <20090409225212.GA8386@us.ibm.com>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
	<1239107264-21775-34-git-send-email-orenl@cs.columbia.edu>
	<20090409210302.GA5115@us.ibm.com>
	<49DE72F7.9040001@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49DE72F7.9040001-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> The task address space (task->mm) may be shared between processes if
> >> CLONE_VM is used, and particularly among threads. Accordingly, treat
> >> 'task->mm' as a shared object: during checkpoint check against the
> >> objhash and only dump the contents if seen for the first time. During
> >> restart, likewise, only restore if it's a new instance, otherwise use
> >> the one already registered in the objhash.
> >>
> >> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> > 
> > Cool.
> > 
> > Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Although:
> > 
> >> +	/* if the mm's objref is in the objhash, use that instance */
> >> +	mm = cr_obj_get_by_ref(ctx, hh->objref, CR_OBJ_MM);
> >> +	if (IS_ERR(mm)) {
> >> +		ret = PTR_ERR(mm);
> >> +		goto out;
> >> +	}
> >>
> >> +	if (mm) {
> >> +		if (mm != current->mm) {
> > 
> > In what twisted world could mm == current->mm at restart?
> 
> Tasks are re-created in user space, and so are threads. So threads will
> already have their 'mm' set correctly.

Doesn't that assume that one task will complete sys_restart() before it
does clone(CLONE_VM)?  Else sure, the threads will already share an mm,
but it'll be the wrong one?  And I didn't think the sys_restart()
synchronization supported that order.

(I realize I'm probably completely misunderstanding, and sounding like
an idiot...)

And since OpenVZ has never re-sent their patch to do task creation in
kernel-space on top of your set, I won't even debate about re-creation
in user-space being certain  :)

-serge

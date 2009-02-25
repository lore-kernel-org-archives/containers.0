From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] c/r: define s390-specific checkpoint-restart code (v6)
Date: Wed, 25 Feb 2009 17:34:54 -0600
Message-ID: <20090225233454.GA29972@us.ibm.com>
References: <1235585529-806-1-git-send-email-danms@us.ibm.com>
	<1235585529-806-4-git-send-email-danms@us.ibm.com>
	<20090225162817.2003383c@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090225162817.2003383c-4v5LP+xe+1byhTdZtsIeww@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > +#if 0
> > +	/* Oren's v13 is on an older kernel which has no vdso_base
> > +	 * on newer kernel, we'll have to enable this
> > +	 */
> > +	CR_COPY(op, hh->vdso_base, mm->context.vdso_base);
> > +#endif
> 
> During restart, does this replace the current task's VDSO contents, and
> if so, is that wise?  VDSO areas contain things like timestamps for
> gettimeofday()...

(I've gone back and forth on this, and the following answer differs
from any interpretation i've had before :)

Well, arch_setup_additional_pages() uses get_unmapped_area() to get
a user mapping for the vdso pages.  So i would expect that in fact
the arch-independent code would set up a new vdso mapping at the
checkpointed location, and so mm->context.vdso_base does in fact
need to be changed.

But it's something to verify when we port the code to a newer
kernel.

-serge

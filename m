From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 07/23] Restore memory address space
Date: Mon, 23 Mar 2009 10:01:25 -0500
Message-ID: <20090323150125.GA888@us.ibm.com>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
	<1237574868-3371-8-git-send-email-orenl@cs.columbia.edu>
	<20090320235433.GA19565@us.ibm.com>
	<49C6B2F6.6080304@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C6B2F6.6080304-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
> >> +	ret = -EINVAL;
> >> +	if (hh->vdso != (unsigned long) mm->context.vdso)
> >> +		goto out;
> > 
> > We were just talking about vdso+s390 on irc this morning,
> > wondering about how to handle it...
> > 
> > Looking at arch/x86/vdso/vma.c, this seems like it should
> > pretty much always error out.  The vdso base is set as a
> > random offset above the stack base at exec().
> 
> Yes, I was wondering too ... :(
> 
> The default config is CONFIG_COMPAT_VDSO which disabled the
> randomization, that's why it works for the default case on X86_32.
> 
> I think the code is mainly in arch/x86/vdso/vdso32_setup.c.

We may earn the ire of the community once again, but it seems to
me we have no choice but to tweak arch_setup_additional_pages()
to take an optional requested location.  Then binfmt->load_binary()
can pass NULL to indicate business as usual, while sys_restart()
can pass the saved vdso_base.

-serge

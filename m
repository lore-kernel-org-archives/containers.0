From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH ghak32 V2 10/13] audit: add containerid support for
	seccomp and anom_abend records
Date: Thu, 19 Apr 2018 20:42:18 -0400
Message-ID: <20180420004218.tgndd474wgueyjzk__19917.0252927162$1524185206$gmane$org@madcap2.tricolour.ca>
References: <cover.1521179281.git.rgb@redhat.com>
	<11174597083f89352f1d6491ec94e27f882625d9.1521179281.git.rgb@redhat.com>
	<CAHC9VhS6MKoLkzpfcmYBSNnvrtbL2FOF5PX9uOfivSVEWykkQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAHC9VhS6MKoLkzpfcmYBSNnvrtbL2FOF5PX9uOfivSVEWykkQg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2018-04-18 21:31, Paul Moore wrote:
> On Fri, Mar 16, 2018 at 5:00 AM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > Add container ID auxiliary records to secure computing and abnormal end
> > standalone records.
> >
> > Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > ---
> >  kernel/auditsc.c | 10 ++++++++--
> >  1 file changed, 8 insertions(+), 2 deletions(-)
> >
> > diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> > index 7103d23..2f02ed9 100644
> > --- a/kernel/auditsc.c
> > +++ b/kernel/auditsc.c
> > @@ -2571,6 +2571,7 @@ static void audit_log_task(struct audit_buffer *ab)
> >  void audit_core_dumps(long signr)
> >  {
> >         struct audit_buffer *ab;
> > +       struct audit_context *context = audit_alloc_local();
> 
> Looking quickly at do_coredump() I *believe* we can use current here.
> 
> >         if (!audit_enabled)
> >                 return;
> > @@ -2578,19 +2579,22 @@ void audit_core_dumps(long signr)
> >         if (signr == SIGQUIT)   /* don't care for those */
> >                 return;
> >
> > -       ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
> > +       ab = audit_log_start(context, GFP_KERNEL, AUDIT_ANOM_ABEND);
> >         if (unlikely(!ab))
> >                 return;
> >         audit_log_task(ab);
> >         audit_log_format(ab, " sig=%ld res=1", signr);
> >         audit_log_end(ab);
> > +       audit_log_container_info(context, "abend", audit_get_containerid(current));
> > +       audit_free_context(context);
> >  }
> >
> >  void __audit_seccomp(unsigned long syscall, long signr, int code)
> >  {
> >         struct audit_buffer *ab;
> > +       struct audit_context *context = audit_alloc_local();
> 
> We can definitely use current here.

Ok, so both syscall aux records.  That elimintes this patch from the
set, can go in independently.

> > -       ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_SECCOMP);
> > +       ab = audit_log_start(context, GFP_KERNEL, AUDIT_SECCOMP);
> >         if (unlikely(!ab))
> >                 return;
> >         audit_log_task(ab);
> > @@ -2598,6 +2602,8 @@ void __audit_seccomp(unsigned long syscall, long signr, int code)
> >                          signr, syscall_get_arch(), syscall,
> >                          in_compat_syscall(), KSTK_EIP(current), code);
> >         audit_log_end(ab);
> > +       audit_log_container_info(context, "seccomp", audit_get_containerid(current));
> > +       audit_free_context(context);
> >  }
> >
> >  struct list_head *audit_killed_trees(void)
> 
> -- 
> paul moore
> www.paul-moore.com
> 
> --
> Linux-audit mailing list
> Linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
> https://www.redhat.com/mailman/listinfo/linux-audit

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635

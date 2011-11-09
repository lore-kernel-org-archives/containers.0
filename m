From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 1/6] user namespace: make signal.c respect user
	namespaces (v4)
Date: Wed, 9 Nov 2011 08:18:53 -0600
Message-ID: <20111109141853.GB4010__48189.7699567073$1320861262$gmane$org@sergelap>
References: <1320445482-8459-1-git-send-email-serge@hallyn.com>
	<1320445482-8459-2-git-send-email-serge@hallyn.com>
	<20111108162216.1ffb3e9a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111108162216.1ffb3e9a.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: richard-/L3Ra7n9ekc@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Fri,  4 Nov 2011 22:24:37 +0000
> Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > +static inline void fixup_uid(struct siginfo *info, struct task_struct *t)
> > +{
> > +#ifdef CONFIG_USER_NS
> > +	if (current_user_ns() == task_cred_xxx(t, user_ns))
> > +#endif
> > +		return;
> > +
> > +	if (SI_FROMKERNEL(info))
> > +		return;
> > +
> > +	info->si_uid = user_ns_map_uid(task_cred_xxx(t, user_ns),
> > +					current_cred(), info->si_uid);
> > +}
> 
> err, this function is a no-op if CONFIG_USER_NS=n.  If that was
> intentional then why on earth do this in such a weird fashion?  If

(I didn't write it, but)  I think the assumption was that the compiler
would optimize it all away if !CONFIG_USER_NS, and in this way the
call site didn't need to be obscured with the #ifdef.  Is there a way
that's better?  Would you prefer something like:

+#ifdef CONFIG_USER_NS
+static inline void fixup_uid(struct siginfo *info, struct task_struct *t)
+{
+	if (current_user_ns() == task_cred_xxx(t, user_ns))
+		return;
+
+	if (SI_FROMKERNEL(info))
+		return;
+
+	info->si_uid = user_ns_map_uid(task_cred_xxx(t, user_ns),
+					current_cred(), info->si_uid);
+}
+#else
+static inline void fixup_uid(struct siginfo *info, struct task_struct *t)
+{
+		return;
+}
+#endif

?  It's less sneaky at least.

> unintentional then it makes me wonder how well tested all this was with
> CONFIG_USER_NS=n?
> 
> I vaguely remember that I've forgotten how all this stuff works.  Some
> additional review input would be nice (cough-oleg-cough).
> 

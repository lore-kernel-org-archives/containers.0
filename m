From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/10] userns: Add per user namespace sysctls.
Date: Wed, 20 Jul 2016 11:43:47 -0500
Message-ID: <20160720164347.GA24378@mail.hallyn.com>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<20160720012138.7894-1-ebiederm@xmission.com>
	<20160720012138.7894-2-ebiederm@xmission.com>
	<20160720051226.GC16885@mail.hallyn.com>
	<87shv49ud0.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87shv49ud0.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> +static bool setup_userns_sysctls(struct user_namespace *ns)
> >> +{
> >> +#ifdef CONFIG_SYSCTL
> >> +	struct ctl_table *tbl;
> >> +	setup_sysctl_set(&ns->set, &set_root, set_is_seen);
> >> +	tbl = kmemdup(userns_table, sizeof(userns_table), GFP_KERNEL);
> >> +	if (tbl) {
> >> +		ns->sysctls = __register_sysctl_table(&ns->set, "userns", tbl);
> >> +	}
> >
> > What happens if tbl is null due to oom?  Would it be better to just
> > return false in that case here?
> 
> ns->sysctls is initialized to NULL and kfree(NULL) is a noop.
> So I don't see any problems.
> 
> I admit it isn't a usual pattern for error handling.

Right I didn't mean that - I meant, is there a way that a namespace
could end up escaping its limits as a result?  I think not, since
either it has hierarchical limits which will still be enforced, or
the admin tries to set a new limit and that step will fail visibly,
which suffices.

thanks,
-serge

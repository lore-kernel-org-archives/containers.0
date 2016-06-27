From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 2/2] namespaces: add transparent user namespaces
Date: Mon, 27 Jun 2016 10:09:42 -0500
Message-ID: <87mvm6y8g9.fsf@x220.int.ebiederm.org>
References: <CAG48ez3ELMSsWhe9X_uq_3M7TjJxq=SnAr09g72nTkCRQY008g@mail.gmail.com>
	<1466814210-3778-1-git-send-email-jannh@google.com>
	<1466814210-3778-2-git-send-email-jannh@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1466814210-3778-2-git-send-email-jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> (Jann Horn's
	message of "Sat, 25 Jun 2016 02:23:30 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jann Horn <jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Calvin Owens <calvinowens-b10kYP2dOMg@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Added a few more relevant cc's.

Jann Horn <jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> writes:

> This allows the admin of a user namespace to mark the namespace as
> transparent. All other namespaces, by default, are opaque.


I have just skimmed through this and at a high level this doesn't seem
too scary.  Having an identity mapped user namespace that just limits
you to using a subset of uids and gids while allowing displaying the
full range of uids and gids.

I don't quite get the use case and I would like to a little better
but in the long term this shouldn't cause any significant maintenance
issues, so I don't have any objects.

At the same time this isn't quite the time to merge this.  I am in the
process of slowly going through Seth's vfs changes to support things
such as truly unprivileged fuse support.  Those changes alter which
places can always be assumed to be init_user_ns (many fewer), and also
slightly change the set of from_kuid calls being made.

The changes that have made it through my review currently reside at:

    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-next

Those vfs changes make it conceivable and simple from an infrastructure
standpoint to transition fileystems to unprivileged user namespace
mounts, with perhaps as little work as just setting FS_USER_NS.  At the
same time that won't be recommend because of the difficulty verifying
evil filesystem contents can't cause fs implementations to do bad things
is difficult.

That change means your first patch that just zaps all from_kuid_munged
users in init_user_ns isn't a particularly good idea.  I don't think it
is a good idea to have one set of rules for things that will always be
init_user_ns and another set of rules for code that will change.

The long and short of this is I am asking you to wait a week or so and
rebase this on my for-next branch so that we can confirm this change
interacts nicely will all of the other on-going work.

Thank you,
Eric Biederman

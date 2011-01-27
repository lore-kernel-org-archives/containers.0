From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] cgroup : remove the ns_cgroup
Date: Wed, 26 Jan 2011 16:16:48 -0800
Message-ID: <20110126161648.39af9576.akpm__24037.4906374656$1296087457$gmane$org@linux-foundation.org>
References: <1295948388-15108-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1295948388-15108-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 25 Jan 2011 10:39:48 +0100
Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:

> The ns_cgroup is an annoying cgroup at the namespace / cgroup frontier
> and leads to some problems:
> 
>         * cgroup creation is out-of-control
>         * cgroup name can conflict when pids are looping
>         * it is not possible to have a single process handling
>         a lot of namespaces without falling in a exponential creation time
>         * we may want to create a namespace without creating a cgroup
> 
>         The ns_cgroup was replaced by a compatibility flag 'clone_children',
>         where a newly created cgroup will copy the parent cgroup values.
>         The userspace has to manually create a cgroup and add a task to
>         the 'tasks' file.
> 
> This patch removes the ns_cgroup as suggested in the following thread:
> 
> https://lists.linux-foundation.org/pipermail/containers/2009-June/018616.html
> 
> The 'cgroup_clone' function is removed because it is no longer used.
> 
> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Jamal Hadi Salim <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
> Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>
> ...
>
>  22 files changed, 4 insertions(+), 287 deletions(-)

I didn't see that one coming.

This change is userspace-visible, is it not?  What are the implications
of this?  There's some discussion in that nearly-two-year-old thread
regarding making provision for back-compatibility but I'm not seeing
such things in this patch?

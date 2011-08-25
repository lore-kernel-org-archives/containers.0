From: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: introduce cgroup_taskset and use it in
	subsys->can_attach(), cancel_attach() and attach()
Date: Thu, 25 Aug 2011 02:32:59 -0700
Message-ID: <CALdu-PAPO7L0yW1ZfZUPuPLjVmW_euO24P-gd3tCY5zFq0FD2g__49239.5489513457$1314264893$gmane$org@mail.gmail.com>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314138000-2049-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 23, 2011 at 3:19 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> +Called prior to moving one or more tasks into a cgroup; if the
> +subsystem returns an error, this will abort the attach operation.
> +@tset contains the tasks to be attached and is guaranteed to have at
> +least one task in it. If there are multiple, it's guaranteed that all
> +are from the same thread group, @tset contains all tasks from the
> +group whether they're actually switching cgroup or not, and the first
> +task is the leader.

I'd reformat this a bit for clarity:

If there are multiple tasks in the taskset, then:
  - it's guaranteed that all are from the same thread group
  - @tset contains all tasks from the thread group whether or not
they're switching cgroup
  - the first task is the leader

Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>

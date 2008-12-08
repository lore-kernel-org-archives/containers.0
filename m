From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] cgroups: skip processes from other namespaces when
	listing a cgroup
Date: Mon, 08 Dec 2008 08:31:29 -0800
Message-ID: <1228753889.9737.10.camel@nimitz>
References: <493BE1A9.8030503@linux.vnet.ibm.com>
	<20081208151412.GN13333@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081208151412.GN13333-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2008-12-08 at 20:44 +0530, Balbir Singh wrote:
> * gowrishankar <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> [2008-12-07 20:16:01]:
> >     struct cgroup_iter it;
> >     struct task_struct *tsk;
> >     cgroup_iter_start(cgrp, &it);
> >     while ((tsk = cgroup_iter_next(cgrp, &it))) {
> >         if (unlikely(n == npids))
> >             break;
> > -        pidarray[n++] = task_pid_vnr(tsk);
> > +        if ((vpid = task_pid_vnr(tsk)) > 0)
> > +            pidarray[n++] = vpid;
> >     }
> >     cgroup_iter_end(cgrp, &it);
> >     return n;

One more thing...

Please cc Eric and Suka on patches like this.  If we get many users like
this we'll probably want to add some common function.  Or if someone
missed using one, they can probably suggest one.

-- Dave

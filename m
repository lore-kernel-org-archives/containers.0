From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: Freezing and task move race fix
Date: Tue, 10 Aug 2010 14:57:41 -0700
Message-ID: <20100810215741.GC2927__20146.6190199882$1281477607$gmane$org@count0.beaverton.ibm.com>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1281470001-14320-1-git-send-email-tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 10, 2010 at 09:53:21PM +0200, Tomasz Buchert wrote:
> Writing 'FROZEN' to freezer.state file does not
> forbid the task to be moved away from its cgroup
> (for a very short time). Nevertheless the moved task
> can become frozen OUTSIDE its cgroup which puts
> discussed task in a permanent 'D' state.
> 
> This patch forbids migration of either FROZEN
> or FREEZING tasks.
> 
> This behavior was observed and easily reproduced on
> a single core laptop. Program and instructions how
> to reproduce the bug can be fetched from:
> http://pentium.hopto.org/~thinred/repos/linux-misc/freezer_bug.c

Thanks for the report and the test code.

I'm will try to reproduce this race in the next few hours and analyze
it since I'm not sure the patch really fixes the race -- it may only
make the race trigger less frequently.

At the very least the patch won't break the current code since it's
essentially a more-strict version of is_task_frozen_enough() -- it lets
fewer tasks attach/detach to/from frozen cgroups.

Cheers,
	-Matt Helsley

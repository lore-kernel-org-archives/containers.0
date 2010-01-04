From: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc-start: Device or resource busy - failed to remove previous
	cgroup
Date: Mon, 4 Jan 2010 06:52:54 +0530
Message-ID: <661de9471001031722o21c6bd55kb73403c85a8145e3@mail.gmail.com>
References: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jan 4, 2010 at 6:40 AM, Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> I'm starting to get is quite regularly, but not every time:
>
> lxc-start: Device or resource busy - failed to remove previous cgroup
> '/cgroup/CONTAINER_NAME'
>

Can you please paste the output of cat /proc/cgroups and cat /proc/mounts

> lxc version: 0.6.3
>
> Cgroup memory controller: disabled (everything else is enabled)
>

Oh! man...

> Linux version 2.6.30-bpo.1-amd64 (Debian 2.6.30-6~bpo50+1)
> (nobse-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #1 SMP Mon
> Aug 17 08:42:50 UTC 2009
>
> This only seems to be happening when the primary started in the
> container exits before all child processes have exited.
>
> I've not seem this happen with lxc-stop, only when quitting a "pseudo"
> init process.
>
> I've tried destroying and recreating the container, un=mounting and
> remounting the given container, none work in that situation. Rebooting
> the root-node does correct the problem.
>

This should not really happen, /proc/cgroups will help us figure out what
is going on. As an alternative, if you can compile the debug cgroup container,
you'll get a lot of useful debug information (CONFIG_CGROUP_DEBUG).

Balbir

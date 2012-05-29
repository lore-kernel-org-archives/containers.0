From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Tue, 29 May 2012 12:24:23 +0400
Message-ID: <4FC487B7.6090505__23488.9537365691$1338280012$gmane$org@parallels.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338260214-21919-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 05/29/2012 06:56 AM, Gao feng wrote:
> cgroup and namespaces are used for creating containers but some of
> information is not isolated/virtualized. This patch is for isolating /proc/meminfo
> information per container, which uses memory cgroup. By this, top,free
> and other tools under container can work as expected(show container's
> usage) without changes.
>
> This patch is a trial to show memcg's info in /proc/meminfo if 'current'
> is under a memcg other than root.
>
> we show /proc/meminfo base on container's memory cgroup.
> because there are lots of info can't be provide by memcg, and
> the cmds such as top, free just use some entries of /proc/meminfo,
> we replace those entries by memory cgroup.
>
> if container has no memcg, we will show host's /proc/meminfo
> as before.
>
> there is no idea how to deal with Buffers,I just set it zero,
> It's strange if Buffers bigger than MemTotal.
>
> Signed-off-by: Gao feng<gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

This is the very same problem that exists with CPU cgroup.
So I'll tell you what kind of resistance we faced, and why I sort of 
agree with it.

In summary, there is no guarantee that current wants to see this. This 
is true for containers environments, but doing this unconditionally can
break applications out there.

With cpu is easier to demonstrate, because you would still see all other 
tasks in the system (no pid namespaces used), but the tick figures won't 
match. But not only memory falls prey to the same issue,
but we really need a common solution to that.

A flag is too ugly, or mount options are too ugly, and when parenting is 
in place, hard to get right.

So I've seen a lot of people advocating we should just use a userspace 
filesystem that would bind mount that ontop of normal proc.

For instance: bind mount your special meminfo into /proc/meminfo inside 
a container. Reads of the later would redirect to the former, that would 
then assemble the proper results from the cgroup filesystem, and display it.

I do believe this is a more neutral way to go, and we have all the 
tools. It also does not risk breaking anything, since only people that 
want it would use it.

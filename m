From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Wed, 30 May 2012 14:38:25 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1205301433490.9716__45118.8043611639$1338413953$gmane$org@chino.kir.corp.google.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
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

On Tue, 29 May 2012, Gao feng wrote:

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
> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Nack, this type of thing was initially tried with cpusets when a thread 
was bound to a subset of nodes, i.e. only show the total amount of memory 
spanned by those nodes.

For your particular interest, this information is already available 
elsewhere: memory.limit_in_bytes and memory.usage_in_bytes and that should 
be the interface where this is attained via /proc/cgroups.

Why?  Because the information exported by /proc/meminfo is considered by 
applications to be static whereas the limit of a memcg may change without 
any knowledge of the application.  Applications which need to know the 
amount of memory they are constrained to are assuming that there are no 
other consumers of memory on the system and thus they should be written to 
understand memcg limits just like they should understand cpusets (through 
either /proc/cgroups or /proc/cpuset).

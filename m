From: KOSAKI Motohiro <kosaki.motohiro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Wed, 30 May 2012 20:22:16 -0400
Message-ID: <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w__23124.0107831129$1338423771$gmane$org@mail.gmail.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
	<alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
	<4FC6B68C.2070703@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4FC6B68C.2070703-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 30, 2012 at 8:08 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> (2012/05/31 6:38), David Rientjes wrote:
>>
>> On Tue, 29 May 2012, Gao feng wrote:
>>
>>> cgroup and namespaces are used for creating containers but some of
>>> information is not isolated/virtualized. This patch is for isolating
>>> /proc/meminfo
>>> information per container, which uses memory cgroup. By this, top,free
>>> and other tools under container can work as expected(show container's
>>> usage) without changes.
>>>
>>> This patch is a trial to show memcg's info in /proc/meminfo if 'current'
>>> is under a memcg other than root.
>>>
>>> we show /proc/meminfo base on container's memory cgroup.
>>> because there are lots of info can't be provide by memcg, and
>>> the cmds such as top, free just use some entries of /proc/meminfo,
>>> we replace those entries by memory cgroup.
>>>
>>> if container has no memcg, we will show host's /proc/meminfo
>>> as before.
>>>
>>> there is no idea how to deal with Buffers,I just set it zero,
>>> It's strange if Buffers bigger than MemTotal.
>>>
>>> Signed-off-by: Gao feng<gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>>
>>
>> Nack, this type of thing was initially tried with cpusets when a thread
>> was bound to a subset of nodes, i.e. only show the total amount of memory
>> spanned by those nodes.
>>
>
> Hmm. How about having memory.meminfo under memory cgroup directory and
> use it with bind mount ? (container tools will be able to help it.)
> Then, container applications(top,free,etc..) can read the values they wants.
> If admins don't want it, they'll not use bind mount.

+1. 50% users need namespace separation and others don't. We need a
selectability.

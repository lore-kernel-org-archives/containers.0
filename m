From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Thu, 31 May 2012 14:36:21 +0900
Message-ID: <4FC70355.70805__39521.723209373$1338442723$gmane$org@jp.fujitsu.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
	<alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
	<4FC6B68C.2070703@jp.fujitsu.com>
	<CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com>
	<4FC6BC3E.5010807@jp.fujitsu.com>
	<alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com>
	<4FC6C111.2060108@jp.fujitsu.com>
	<alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com>
	<4FC6D881.4090706@jp.fujitsu.com>
	<alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1205302156090.25774-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, KOSAKI Motohiro <kosaki.motohiro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/05/31 14:02), David Rientjes wrote:
> On Thu, 31 May 2012, Kamezawa Hiroyuki wrote:
>
>>> It's not just a memcg issue, it would also be a cpusets issue.
>>
>> I think you can add cpuset.meminfo.
>>
>
> It's simple to find the same information by reading the per-node meminfo
> files in sysfs for each of the allowed cpuset mems.  This is why this
> approach has been nacked in the past, specifically by Paul Jackson when he
> implemented cpusets.
>

I don't think there was a discussion of LXC in that era.

> The bottomline is that /proc/meminfo is one of many global resource state
> interfaces and doesn't imply that every thread has access to the full
> resources.  It never has.  It's very simple for another thread to consume
> a large amount of memory as soon as your read() of /proc/meminfo completes
> and then that information is completely bogus.

Why you need to discuss this here ? We know all information are snapshot.

> We also don't want to
> virtualize every single global resource state interface, it would be never
> ending.
>
Just doing one by one. It will end.

> Applications that administer memory cgroups or cpusets can get this
> information very easily, each application within those memory cgroups or
> cpusets does not need it and should not rely on it: it provides no
> guarantee about future usage nor notifies the application when the amount
> of free memory changes.

If so, the admin should have know-how to get the information from the inside
of the container. If container is well-isolated, he'll need some
trick to get its own cgroup information from the inside of containers.

Hmm....maybe need to mount cgroup in the container (again) and get an access to cgroup
hierarchy and find the cgroup it belongs to......if it's allowed. I don't want to allow
it and disable it with capability or some other check. Another idea is to exchange
information by some network connection with daemon in root cgroup, like qemu-ga.
And free, top, ....misc applications should support it. It doesn't seem easy.

It may be better to think of supporting yet another FUSE procfs, which will work
with libvirt in userland if having it in the kernel is complicated.

Thanks,
-Kame

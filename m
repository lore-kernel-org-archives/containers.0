From: KOSAKI Motohiro <kosaki.motohiro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Thu, 31 May 2012 03:42:38 -0400
Message-ID: <4FC720EE.3010307__5535.3794516579$1338450168$gmane$org@gmail.com>
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
	<4FC70355.70805@jp.fujitsu.com>
	<alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com>
	<4FC70E5E.1010003@gmail.com>
	<alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com>
	<4FC711A5.4090003@gmail.com>
	<alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com>
	<CAHGf_=qVDVT6VW2j9gE3bQKwizW24iivrDryiCKoxVu4m_fWKw@mail.gmail.com>
	<alpine.DEB.2.00.1205310028420.8864@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1205310028420.8864-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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

(5/31/12 3:35 AM), David Rientjes wrote:
> On Thu, 31 May 2012, KOSAKI Motohiro wrote:
>
>>> As I said, LXC and namespace isolation is a tangent to the discussion of
>>> faking the /proc/meminfo for the memcg context of a thread.
>>
>> Because of, /proc/meminfo affect a lot of libraries behavior. So, it's not only
>> application issue. If you can't rewrite _all_ of userland assets, fake meminfo
>> can't be escaped. Again see alternative container implementation.
>>
>
> It's a tangent because it isn't a complete psuedo /proc/meminfo for all
> threads attached to a memcg regardless of any namespace isolation; the LXC
> solution has existed for a couple of years by its procfs patchset that
> overlaps procfs with fuse and can suppress or modify any output in the
> context of a memory controller using things like
> memory.{limit,usage}_in_bytes.  I'm sure all other fields could be
> modified if outputted in some structured way via memcg; it looks like
> memory.stat would need to be extended to provide that.  If that's mounted
> prior to executing the application, then your isolation is achieved and
> all libraries should see the new output that you've defined in LXC.
>
> However, this seems like a seperate topic than the patch at hand which
> does this directly to /proc/meminfo based on a thread's memcg context,
> that's the part that I'm nacking.

Then, I NAKed current patch too. Yeah, current one is ugly. It assume _all_
user need namespace isolation and it clearly is not.


> I'd recommend to Gao to expose this
> information via memory.stat and then use fuse and the procfs lxc support
> as your way of contextualizing the resources.

It's one of a option. But, I seriously doubt fuse can make simpler than kamezawa-san's
idea. But yeah, I might NACK kamezawa-san's one if he will post ugly patch.

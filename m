From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Date: Thu, 31 May 2012 17:51:28 +0900
Message-ID: <4FC73110.6010107__1666.00002344257$1338454462$gmane$org@jp.fujitsu.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
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
	<4FC720EE.3010307@gmail.com> <4FC724B1.70508@cn.fujitsu.com>
	<4FC72CA4.6080708@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4FC72CA4.6080708-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, KOSAKI Motohiro <kosaki.motohiro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/05/31 17:32), Glauber Costa wrote:
> On 05/31/2012 11:58 AM, Gao feng wrote:
>>> > It's one of a option. But, I seriously doubt fuse can make simpler than kamezawa-san's
>>> > idea. But yeah, I might NACK kamezawa-san's one if he will post ugly patch.
>>> >
>> It seams I should do some homework to make the implement beautifully.
>>
>> I think kamezawa-san's idea is more simpler.
>> thanks for your advice.
>>
>
> One think to keep in mind: A file in memcg does not need to follow the same format
> of /proc/meminfo so we can bind mount. We should be able to reconstruct that in
>  userspace based on information available from the kernel. You can even collect that
>from multiple locations, and *then* you bind mount.

I'm sorry I couldn't fully understand. Could you explain more ?
Do you mean
  - bind mount memory cgroup directory into the container for exporting information
  - Some user-space apps, FUSE-procfs or some, can provide enough information

?
Thanks,
-Kame

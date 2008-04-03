From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mm 1/3] cgroup: use a hash table for css_set finding
Date: Thu, 03 Apr 2008 18:13:13 +0800
Message-ID: <47F4ADB9.5040606__45496.1018207998$1207217828$gmane$org@cn.fujitsu.com>
References: <47F470AB.2070904@cn.fujitsu.com>
	<20080403162459.4a90d574.kamezawa.hiroyu@jp.fujitsu.com>
	<47F48C69.2080805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47F48C69.2080805-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

>>> +static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
>>> +{
>>> +	int i;
>>> +	int index;
>>> +	unsigned long tmp = 0UL;
>>> +
>>> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++)
>>> +		tmp += (unsigned long)css[i];
>>> +
>> maybe css[i]'s lower 2-3 bits will be ignored. because thery are always 0.
>>
>> And I don't like "+" for hash. how about
>> ==
>> 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++)
>> 	unsigned long x;
>> 	x = (unsigned long)css[i];
>> 	tmp = (x >> 16) ^ (x & 0xffff)
>> ==
>> or some func, which uses full bits.
>>
> 
> I'm using hash_long(), which has been proved to be a good one. And I've tested
> css_set_hash(), I run the css_set benchmark with N == 1000, the for loop in
> find_existing_css_set() will break out within 10 iterations for most cases, 
> which is the expected result.
> 

I just revised the css_set_hash() a bit, and It turned out we can improve the
scalability.

Thanks, KAMEZAWA-san.

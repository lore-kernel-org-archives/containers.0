From: Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] cgroup: prefer [kv]zalloc over [kv]malloc+memset in
	memory controller code.
Date: Tue, 2 Nov 2010 08:21:43 +0900
Message-ID: <AANLkTinAHXcG+ar2Wd9QjT58OOory_g87Tv4LnN53L-6__45042.7612443038$1288653737$gmane$org@mail.gmail.com>
References: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
	<20101101200122.GH840@cmpxchg.org>
	<alpine.LNX.2.00.1011012056250.12889@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1011012056250.12889-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 2, 2010 at 4:59 AM, Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org> wrote:
> On Mon, 1 Nov 2010, Johannes Weiner wrote:
>
>> On Mon, Nov 01, 2010 at 08:40:56PM +0100, Jesper Juhl wrote:
>> > Hi (please CC me on replies),
>> >
>> >
>> > Apologies to those who receive this multiple times. I screwed up the T=
o:
>> > field in my original mail :-(
>> >
>> >
>> > In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() th=
en
>> > followed by memset() to zero the memory. This can be more efficiently
>> > achieved by using kzalloc() and vzalloc().
>> >
>> >
>> > Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
>>
>> Looks good to me, but there is also the memset after kmalloc in
>> alloc_mem_cgroup_per_zone_info().
>
> Dang, I missed that one. Thanks for pointing it out.
>
> Hmm, I'm wondering if we should perhaps add kzalloc_node()/vzalloc_node()
> just like kzalloc() and vzalloc()..

I am not against that.
As looking code, there are many places to use kzalloc_node but few vzalloc_=
node.
Although it is, Only adding kzalloc_node would make code rather ugly like t=
his.

if (some size > limit)
  ptr =3D  kzalloc_node(...);
else  {
  prt =3D vmalloc_node(...)
  vmalloced =3D 1;
}

if (ptr && vmalloced)
   memset(prt, xxxx);

So if we will add kzalloc_node, we have to add vzalloc_node, too.

>
>> Can you switch that over as well in
>> this patch? =A0You can pass __GFP_ZERO to kmalloc_node() for zeroing.
>>
>
> Sure thing.
>
>
> Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Reviewed-by: Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

-- =

Kind regards,
Minchan Kim

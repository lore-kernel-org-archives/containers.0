From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] [PATCH] memory controller statistics
Date: Mon, 10 Sep 2007 13:56:57 +0530
Message-ID: <46E4FFD1.4010708@linux.vnet.ibm.com>
References: <20070907033942.4A6541BFA52@siro.lan>
	<46E12020.1060203@linux.vnet.ibm.com>
	<kk5tzq39x7h.fsf@brer.local.valinux.co.jp>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <kk5tzq39x7h.fsf-VZKBDE94do7Xw16qUzMy135BbFPdSy0r@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?UTF-8?B?566V5rWm55yf?= <minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Linux Memory Management List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

=E7=AE=95=E6=B5=A6=E7=9C=9F wrote:
> Takashi is AFK for a while; i'm replying for him as possible.
>=20
>> Thanks for doing this. We are building containerstats for
>> per container statistics. It would be really nice to provide
>> the statistics using that interface. I am not opposed to
>> memory.stat, but Paul Menage recommends that one file has
>> just one meaningful value.
>=20
> Thanks, we'll check it.  The interface is not important for
> us.
>=20
>> The other thing is that could you please report all the
>> statistics in bytes, we are moving to that interface,
>> I've posted patches to do that. If we are going to push
>> a bunch of statistics in one file, please use a format
>> separator like
>=20
>> name: value
>=20
>>> YAMOMOTO Takshi
>>>
>>> todo: something like nr_active/inactive in /proc/vmstat.
>>>
>=20
>> This would be really nice to add.
>=20
> `something' here could be # of pages (in bytes according to
> your advice) on the global active (or inactive) list that
> are charged to a container, and/or # of pages on the
> per-container active/inactive list.  The latter is easy to
> implement but I'm afraid it's somewhat confusing for users.
>=20

I think it would be useful for administrators to get a rough
idea of the working set (active bytes), to configure the size
of the container.

--=20
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH RFC v0 2/3] res_counter: implement thresholds
Date: Fri, 27 Nov 2009 08:38:39 +0530
Message-ID: <661de9470911261908i4bb51e91v649025e6c75bd91b__45780.5636724972$1259291395$gmane$org@mail.gmail.com>
References: <cover.1259255307.git.kirill@shutemov.name>
	<bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259255307.git.kirill@shutemov.name>
	<8524ba285f6dd59cda939c28da523f344cdab3da.1259255307.git.kirill@shutemov.name>
	<20091127092035.bbf2efdc.nishimura@mxp.nes.nec.co.jp>
	<20091127114511.bbb43d5a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091127114511.bbb43d5a.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 27, 2009 at 8:15 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> On Fri, 27 Nov 2009 09:20:35 +0900
> Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
>
>> Hi.
>> >
>> > @@ -73,6 +76,7 @@ void res_counter_uncharge_locked(struct res_counter =
*counter, unsigned long val)
>> > =A0 =A0 =A0 =A0 =A0 =A0 val =3D counter->usage;
>> >
>> > =A0 =A0 counter->usage -=3D val;
>> > + =A0 res_counter_threshold_notify_locked(counter);
>> > =A0}
>> >
>> hmm.. this adds new checks to hot-path of process life cycle.
>>
>> Do you have any number on performance impact of these patches(w/o settin=
g any threshold)?
>> IMHO, it might be small enough to be ignored because KAMEZAWA-san's coal=
esce charge/uncharge
>> patches have decreased charge/uncharge for res_counter itself, but I wan=
t to know just to make sure.
>>
> Another concern is to support root cgroup, you need another notifier hook=
 in
> memcg because root cgroup doesn't use res_counter now.
>
> Can't this be implemented in a way like softlimit check ?
> Filter by the number of event will be good for notifier behavior, for avo=
iding
> too much wake up, too.

I guess the semantics would vary then, they would become activity
semantics. I think we should avoid threshold notification for root,
since we have no limits in root anymore.

BTW, Kirill, I've been meaning to write this layer on top of
cgroupstats, is there anything that prevents us from using that today?
CC'ing Dan Malek and Vladslav Buzov who worked on similar patches
earlier.

Balbir Singh.

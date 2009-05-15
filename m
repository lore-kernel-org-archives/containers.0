From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband
	supporting the predicable I/O bandwidth (range bandwidth)
Date: Fri, 15 May 2009 16:00:00 +0900
Message-ID: <2891419e0905150000x5f19908eh975c83690f38b9ac__10091.690431773$1242370858$gmane$org@mail.gmail.com>
References: <2891419e0905040423y27f25ce7y61e5211aded85f99@mail.gmail.com>
	<20090505.073655.193711315.ryov@valinux.co.jp>
	<2891419e0905051735s7371e590gc942e4c6c475aa67@mail.gmail.com>
	<20090512.203014.71110404.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090512.203014.71110404.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Ryo.

Sorry for late reply.

2009/5/12 Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>:
> Hi Dong-Jae,
>> >> after bug-fix,I evaluated range-bw according to your configuration and
>> >> test environment
>> >> the result is in new relesed range-bw mail, [PATCH 0/2]
>> >> and more detailed documentation is also available and it can be
>> >> referred in [PATCH 1/2]
>> >>
>> >> Ryo,
>> >> can you check the result ?
>
> I did the same test as before and got the results as expected.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup1 =A0 =A0cgroup2
> =A0min:max-bw =A0 =A00:100 =A0 =A0 =A00:200
> =A0-------------------------------------
> =A0read =A0 =A0 =A0 =A0 =A0100 =A0 =A0 =A0 =A0 197
> =A0write =A0 =A0 =A0 =A0 103 =A0 =A0 =A0 =A0 198 [KB/s]
>

I think upper result is reasonable.
because you configured min and  max bandwidth as 0K:100K(for cgroup1)
and 0K:200K(for cgroup2).
So, range-bw supported appropriate and expected bandwidth with 1~3% error r=
ange.
minimum bandwidth was satisfied (0K, 0K ) and maximum bandwidth was
limited (100K, 200K)
but there is some considered point in use of range-bw as I described
in [PATCH 0/2] as below.

* Attention
-----------------
Range-BW supports the predicable I/O bandwidth, but it should be
configured in the scope of total I/O bandwidth of the I/O system to
guarantee the minimum I/O requirement. For example, if total I/O
bandwidth is 40Mbytes/sec, the summary of I/O bandwidth configured in
each process group should be equal or smaller than 40Mbytes/sec.
So, we need to check total I/O bandwidth before set it up.

If you need more another information about range-bw, reply to me.

> I got errors while applying your patch, some lines are wrapped with
> carriage returns.
>
> =A0 =A0+extern int policy_range_bw_init(struct ioband_device *dp, int arg=
c,
> =A0>> char **argv);

Thank you for bug reporting
I will check it again.

>
> Thanks,
> Ryo Tsuruta
>



-- =

Best Regards,
Dong-Jae Kang

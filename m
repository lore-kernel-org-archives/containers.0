From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation v4
Date: Thu, 23 Jul 2009 20:26:47 -0700
Message-ID: <2f86c2480907232026v143aef06t652796b489b7ad2c__10093.2321897291$1248406083$gmane$org@mail.gmail.com>
References: <20090723152647.D9391722@kernel> <4A692444.2030303@cn.fujitsu.com>
	<20090724120811.a581eea5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724120811.a581eea5.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 23, 2009 at 8:08 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> On Fri, 24 Jul 2009 11:02:28 +0800
> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
>> Dave Hansen wrote:
>> > Remaining issues:
>> > - How should we deal with out-of-range indexes, especially
>> > =A0 in flex_array_get() which returns void*? =A0ERR_PTR()?
>> > =A0 BUG_ON()? =A0return NULL (current behavior)?
>> > - Should care be taken not to allow a flex_array_get() to
>> > =A0 an index where no flex_array_put() was done?
>> > - Should we decay further than just packing things into the
>> > =A0 'base' page? =A0Should we actually kmalloc() less than a
>> > =A0 page at times when it will fit?
>> >
>>
>> I sugguest find some candidate users and see how this flex_array
>> fits them.
>>
> Hmm, can't we rewrite cgroup->tasks file using this ?
> I'll try some if I have time.
>
> -Kame
>
>
>

I can do that; it would go nicely on top of my procs file patch
series, but probably wants to wait until after both patch series have
been accepted (see http://lkml.org/lkml/2009/7/23/330 )

From: Liu Aleaxander <aleaxander@gmail.com>
Subject: Re: [PATCH 2/3] Fix the 'current css_set' problem in debug subsystem
Date: Tue, 3 Nov 2009 09:21:56 +0800
Message-ID: <b741c2440911021721o610ee4f1la123146e6e503d2d@mail.gmail.com>
References: <b741c2440911012346k7213befcida229606f10c0399@mail.gmail.com>
	 <4AEF81E2.3060403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757545AbZKCBVw@vger.kernel.org>
In-Reply-To: <4AEF81E2.3060403@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 3, 2009 at 9:05 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> Liu Aleaxander wrote:
>>>From 61c93b1a66e43d44820e9b8d22ef0bec80dfc814 Mon Sep 17 00:00:00 20=
01
>> From: Liu Aleaxander <Aleaxander@gmail.com>
>> Date: Mon, 2 Nov 2009 14:30:07 +0800
>> Subject: [PATCH 2/3] Fix the 'current css_set' problem in debug subs=
ystem
>>
>> In the current implementation, it always print the same information
>> no matter which group you are in. And this would be meaningless. So
>> we should make it print the information of the 'real' current one.
>>
>> Well, I am not sure it's the current one, but I'm sure it's the firs=
t
>> one of that cgroup.
>>
>
> I don't think there is a bug with current 'curent_css_set'. The
> "current" in all debug.current_xxx interfaces means "current task".
Yes, I know it means 'current task', but is this useful to print the
same things with two more files in all the cgroups?

> Besides we already print out a cgroup's css links through
> debug.cgroup_css_links, without showing the refcount of
> each css_set, but we can, if it can be useful:
>
> =A0# cat debug.cgroup_css_links
> =A0css_set c10d92e0
Good link:)

--=20
regards
Liu Aleaxander

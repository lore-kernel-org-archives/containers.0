From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm] cgroups: fix failure path in cgroup_write_event_control()
Date: Wed, 24 Feb 2010 15:28:31 +0200
Message-ID: <cc557aab1002240528t28eae36dj976525be2fcf7246@mail.gmail.com>
References: <4B849B73.1040106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B849B73.1040106@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 24, 2010 at 5:22 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> How to reproduce:
>
> =C2=A0# mount -t cgroup -o memory xxx /cgroup
> =C2=A0# mkdir /cgroup/tmp
> =C2=A0# ./cgroup_event_listener /cgroup/tmp/cgroup.event_control abc
> =C2=A0^C
> =C2=A0# rmdir /cgroup/tmp
> =C2=A0# cat /proc/cgroups | grep memory
> =C2=A0memory =C2=A02 =C2=A0 =C2=A0 =C2=A0 2 =C2=A0 =C2=A0 =C2=A0 1 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 (should be "2 1 1")
> =C2=A0# umount /cgroup
> =C2=A0(failed!)
>
> Using a single goto label to cleanup multi failure paths can
> get things wrong quite easily, while multi labels makes the
> code cleaner.

I disagree.
It's easer to make mistake on changing code with multi failure
paths, if you want to move a code within function.

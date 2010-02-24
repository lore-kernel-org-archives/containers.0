From: Paul Menage <menage@google.com>
Subject: Re: [PATCH -mm] cgroups: fix failure path in cgroup_write_event_control()
Date: Wed, 24 Feb 2010 08:06:20 -0800
Message-ID: <6599ad831002240806p69fcbc01l1173dd2ad971dac9@mail.gmail.com>
References: <4B849B73.1040106@cn.fujitsu.com>
	 <cc557aab1002240528t28eae36dj976525be2fcf7246@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cc557aab1002240528t28eae36dj976525be2fcf7246@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 24, 2010 at 5:28 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>>
>> Using a single goto label to cleanup multi failure paths can
>> get things wrong quite easily, while multi labels makes the
>> code cleaner.
>
> I disagree.
> It's easer to make mistake on changing code with multi failure
> paths, if you want to move a code within function.

I'm on Kirill's side here. Being able to have a single "cleanup
everything" error path makes the code a lot more maintainable. It may
be inappropriate for really performance-critical functions, but that's
not the case here.

Paul

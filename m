From: Paul Menage <menage@google.com>
Subject: Re: LSM stacking/secondary modules / RFC: Socket MAC LSM
Date: Thu, 15 Jan 2009 09:29:09 -0800
Message-ID: <6599ad830901150929x75b73886j87582b5b059d8bf1@mail.gmail.com>
References: <1231952907.5315.17.camel@sp-laptop3.sp-local>
	 <f639a5c10901140934w3a019308yb5c5c1d73b605fd5@mail.gmail.com>
	 <20090114180129.GB7337@kroah.com>
	 <1231972131.5315.48.camel@sp-laptop3.sp-local>
	 <20090114231645.GA24111@kroah.com>
	 <1231979170.5315.69.camel@sp-laptop3.sp-local>
	 <20090115004143.GB14467@us.ibm.com>
	 <20090115004407.GA14867@us.ibm.com>
	 <1232027832.14136.8.camel@sp-laptop3.sp-local>
	 <20090115153531.GI17884@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090115153531.GI17884@megiteam.pl>
Sender: linux-security-module-owner@vger.kernel.org
To: Grzegorz Nosek <root@localdomain.pl>
Cc: Stephan Peijnik <stephan@peijnik.at>, "Serge E. Hallyn" <serue@us.ibm.com>, Greg KH <greg@kroah.com>, Rafael Konrath <rafael.konrath@gmail.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Li Zefan <lizf@cn.fujitsu.com>
List-Id: containers.vger.kernel.org

On Thu, Jan 15, 2009 at 7:35 AM, Grzegorz Nosek <root@localdomain.pl> wrote:
>
> I guess the net result would comprise two parts:
>  - iptable_control, possibly based on Paul's code (hook
>   socket/connect/bind/accept calls into iptables)
>  - ipt_cgroup, matching the cgroup the requesting process is a member
>   of (I'd also need a target to remap the source address but it would
>   probably a minor thing to do)
>

Right.

> One thing I'm not quite sure about is matching the cgroups. Should I
> attempt to match the cgroup path? Or some per-cgroup cookie stored in a
> virtual file? Both don't seem too pretty, need help :/

Use an approach similar to the net_cls cgroup subsystem in
net/sched/cls_cgroup.c. (Or possibly just expose and reuse the same
id).

Paul

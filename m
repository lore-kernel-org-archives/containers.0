From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Fri, 19 Nov 2010 18:25:13 +0200
Message-ID: <AANLkTimUYkzgimgLOtEFDKO6ApY=J2QQxr-mz6AQMmoZ@mail.gmail.com>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>
	<4CD3CE29.2010105@kernel.org>
	<20101106053204.GB12449@count0.beaverton.ibm.com>
	<20101106204008.GA31077@sundance.ccs.neu.edu>
	<4CD5D99A.8000402@cs.columbia.edu>
	<20101107184927.GF31077@sundance.ccs.neu.edu>
	<4CD72150.9070705@cs.columbia.edu>
	<4CE3C334.9080401@kernel.org>
	<20101117153902.GA1155@hallyn.com>
	<4CE3F8D1.10003@kernel.org>
	<20101119041045.GC24031@hallyn.com>
	<4CE683E1.6010500@kernel.org>
	<04F4899E-B5C7-4BAF-8F2F-05D507A91408@parallels.com>
	<4CE698C5.5060806@kernel.org>
	<AANLkTikRHuaCpaROtty6X_Oe6JixzgcbVsxHxvtsu+UV@mail.gmail.com>
	<AANLkTikqpv8j-H15qjyhy7RJ92wNsWzeFykVMFKypt13@mail.gmail.com>
	<4CE6A172.7010603@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CE6A172.7010603@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Kirill Korotaev <dev@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pavel Emelianov <xemul@parallels.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 19, 2010 at 6:10 PM, Tejun Heo <tj@kernel.org> wrote:
> Well, if you ask me, having pidns w/o a way to reinstate PID from
> userland is pretty silly

No.
Chrome uses CLONE_PID so that exploit couldn't attach to processes in
parent pidns.

> and you and I might not know yet but it's
> quite imaginable that there will be other use cases for the capabilit=
y
> unlike in-kernel CR. =A0Kernel provides building blocks not the whole
> frigging package and for very good reasons.

Speaking of pids, pid's value itself is never interesing (except maybe =
pid 1).
It's a cookie.

CLONE_SET_PID came up only now because only C/R wants it.

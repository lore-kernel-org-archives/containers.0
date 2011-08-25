From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 19:27:34 +0200
Message-ID: <CAOS58YOSLrfFaUgaDEZyjAPuEHrB9PmVi9TTz=HROtYuwRQuRA@mail.gmail.com>
References: <20110824085329.GL29452@sun>
	<20110824111806.GA7191@albatros>
	<20110825082944.GH10030@sun>
	<20110825170147.GM2803@mtj.dyndns.org>
	<4E5680D2.1030608@parallels.com>
	<20110825172109.GC6387@sun>
	<4E568583.40206@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E568583.40206@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Vasiliy Kulikov <segoon@openwall.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

Hello,

On Thu, Aug 25, 2011 at 7:25 PM, Pavel Emelyanov <xemul@parallels.com> wrote:
> Not exactly - as I said if we leave the name without 0x (3d000000 instead of 0x3d000000)
> this makes it hard to use strtol() on these strings to convert names to addresses.

But strtol() has @base.

Thanks.

-- 
tejun

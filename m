From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 21:34:16 +0400
Message-ID: <20110825173416.GD6387@sun>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
 <20110825170147.GM2803@mtj.dyndns.org>
 <4E5680D2.1030608@parallels.com>
 <20110825172109.GC6387@sun>
 <4E568583.40206@parallels.com>
 <CAOS58YOSLrfFaUgaDEZyjAPuEHrB9PmVi9TTz=HROtYuwRQuRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOS58YOSLrfFaUgaDEZyjAPuEHrB9PmVi9TTz=HROtYuwRQuRA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Vasiliy Kulikov <segoon@openwall.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 07:27:34PM +0200, Tejun Heo wrote:
> Hello,
> 
> On Thu, Aug 25, 2011 at 7:25 PM, Pavel Emelyanov <xemul@parallels.com> wrote:
> > Not exactly - as I said if we leave the name without 0x (3d000000 instead of 0x3d000000)
> > this makes it hard to use strtol() on these strings to convert names to addresses.
> 
> But strtol() has @base.
> 

That's ok. Tejun, i'll think a bit more (probably tomorrow already, since I'll
be reworking it and adding a check for permissions nit you've pointed) and will
check if there is a nice way to make the names longer ;)

	Cyrill

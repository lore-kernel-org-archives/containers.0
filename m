From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH][DOCUMENTATION] Minimal controller code for a quick
	start
Date: Thu, 07 Feb 2008 21:28:57 +0100
Message-ID: <1202416137.6274.42.camel@lappy>
References: <47AB25AD.30400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761279AbYBGU3V@vger.kernel.org>
In-Reply-To: <47AB25AD.30400@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org


On Thu, 2008-02-07 at 18:37 +0300, Pavel Emelyanov wrote:
> The Documentation/cgroups.txt file contains the info on how
> to write some controller for cgroups subsystem, but even with
> this, one need to write quite a lot of code before developing
> the core (or copy-n-paste it from some other place).
> 
> I propose to put this minimal controller into Documentation
> directory to let people copy-n-paste a) from a known place and 
> b) a small piece of code.
> 
> Besides, many people learn better reading an example rather
> than/along with a document.


While on the subject, could someone document struct cgroup_subsys. In
particular, I've wondered why we have: cgroup_subsys::can_attach() and
not use a return value in cgroup_subsys::attach()?

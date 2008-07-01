From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cgroup: support checking of subsystem dependencies (v2)
Date: Tue, 1 Jul 2008 01:54:38 -0700
Message-ID: <20080701015438.43172fd7.akpm@linux-foundation.org>
References: <4858C0ED.2080905@cn.fujitsu.com>
	<6599ad830806181413y5d0ef1bfyfc54c17ee904d744@mail.gmail.com>
	<4859BBA8.6070808@cn.fujitsu.com>
	<20080701005140.ec06af68.akpm@linux-foundation.org>
	<4869EE32.6050708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757456AbYGAIzj@vger.kernel.org>
In-Reply-To: <4869EE32.6050708@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Paul Menage <menage@google.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Jackson <pj@sgi.com>
List-Id: containers.vger.kernel.org

On Tue, 01 Jul 2008 16:43:30 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:

> > The whole patch doesn't do anything.  Perhaps there's another patch in
> > the pipeline somewhere which adds one or more ->subsys_depend
> > implementations, but I cannot find it.  If so, I'd have expected this
> > patch to be titled [1/N].
> > 
> 
> Yes, the patch does nothing actually. Daisuke Nishimura-san's original swap
> controller needed to be mounted with memory controller, but the newer
> version makes it an addon to memory controller, so it currently doesn't
> need the feature this patch provides.
> 
> Or I can keep this patch until some new cgroup subsystem needs it ?

That would be better.  Once something needs this patch, we do

[patch 1/n]: cgroup: support checking of subsystem dependencies
[patch 2/n]: <use it>

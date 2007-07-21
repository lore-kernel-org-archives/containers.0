From: sukadev@us.ibm.com
Subject: Re: [PATCH 4/5] [V2] Define is_global_init() and is_container_init()
Date: Fri, 20 Jul 2007 20:02:54 -0700
Message-ID: <20070721030254.GA5344@us.ibm.com>
References: <20070719071206.GE10195@us.ibm.com> <20070719072158.GD28216@us.ibm.com> <20070720154113.db9fb8a4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935580AbXGUDDM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070720154113.db9fb8a4.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Containers <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Andrew Morton [akpm@linux-foundation.org] wrote:
| On Thu, 19 Jul 2007 00:21:58 -0700
| sukadev@us.ibm.com wrote:
| 
| > --- lx26-22-rc6-mm1a.orig/kernel/pid.c	2007-07-16 12:55:15.000000000 -0700
| > +++ lx26-22-rc6-mm1a/kernel/pid.c	2007-07-16 13:10:48.000000000 -0700
| > @@ -69,6 +69,13 @@ struct pid_namespace init_pid_ns = {
| >  	.last_pid = 0,
| >  	.child_reaper = &init_task
| >  };
| > +EXPORT_SYMBOL(init_pid_ns);
| > +
| > +int is_global_init(struct task_struct *tsk)
| > +{
| > +	return tsk == init_pid_ns.child_reaper;
| > +}
| > +EXPORT_SYMBOL(is_global_init);
| 
| I don't immediately see why init_pid_ns was exported to modules.

| 
| It would need to be exported if is_global_init() was made static inline in a
| header (which seems like a sensible thing to do), but it wasn't.

It did not need to be exported in this patch.

I have a couple of follow-on patches that cleaned up some header-file
dependencies and made is_global_init() inline. Those patches are
changing a bit as I merge them with Pavel Emelianov's pid ns changes.

I will send a separate patch to inline is_global_init().

Suka

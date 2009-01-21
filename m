From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7][v7] Container-init signal semantics
Date: Wed, 21 Jan 2009 12:53:00 +0900
Message-ID: <20090121125300.b5916256.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090117202638.GA11825@us.ibm.com>
	<20090119110906.58ccbcbd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090121030500.GA32138@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763414AbZAUDyU@vger.kernel.org>
In-Reply-To: <20090121030500.GA32138@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, 20 Jan 2009 19:05:00 -0800
Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki [kamezawa.hiroyu@jp.fujitsu.com] wrote:
> | On Sat, 17 Jan 2009 12:26:38 -0800
> | Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> wrote:
> | 
> | > 
> | > Container-init must behave like global-init to processes within the
> | > container and hence it must be immune to unhandled fatal signals from
> | > within the container (i.e SIG_DFL signals that terminate the process).
> | > 
> | > But the same container-init must behave like a normal process to 
> | > processes in ancestor namespaces and so if it receives the same fatal
> | > signal from a process in ancestor namespace, the signal must be
> | > processed.
> | > 
> | > Implementing these semantics requires that send_signal() determine pid
> | > namespace of the sender but since signals can originate from workqueues/
> | > interrupt-handlers, determining pid namespace of sender may not always
> | > be possible or safe.
> | > 
> | 
> | Is this feature is for blocking signals from children to name-space
> | creator(owner) ?  And automatically used when namespace/cgroup is created ?
> | IOW, Container-init is Namespace-Cgroup-init ? 
> 
> I am not sure what "Namespace-cgroup-init refers" to.
> 
> But, yes, this patchset applies to the first process in a pid namespace
> i.e the child of clone(NEWPID) call.
> 
O.K. thank you.

What makes me confused is "Container". There is no "Container" in
the linux kernel, just cgroup and its subsyss.
(Some source codes still use "cont" but new codes all use "cgroup" or "cgrp" )

So, I asked whether "Container" means "Namespace subsys" or something different.

-Kame

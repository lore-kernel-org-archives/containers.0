From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/7][v7] Container-init signal semantics
Date: Tue, 20 Jan 2009 20:16:40 -0800
Message-ID: <m1k58pwaxj.fsf@fess.ebiederm.org>
References: <20090117202638.GA11825@us.ibm.com>
	<20090119110906.58ccbcbd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090121030500.GA32138@us.ibm.com>
	<20090121125300.b5916256.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763648AbZAUERJ@vger.kernel.org>
In-Reply-To: <20090121125300.b5916256.kamezawa.hiroyu@jp.fujitsu.com> (KAMEZAWA Hiroyuki's message of "Wed\, 21 Jan 2009 12\:53\:00 +0900")
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, oleg@redhat.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> What makes me confused is "Container". There is no "Container" in
> the linux kernel, just cgroup and its subsyss.
> (Some source codes still use "cont" but new codes all use "cgroup" or "cgrp" )
>
> So, I asked whether "Container" means "Namespace subsys" or something different.

"Container" is what we use to refer to the user space concept, that is built
from a set of namespaces and control groups.  A Container that looks like
a standard linux install from the inside is what we expect the most common
use of namespaces and control groups to be.

Eric

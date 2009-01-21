From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7][v7] Container-init signal semantics
Date: Wed, 21 Jan 2009 13:23:37 +0900
Message-ID: <20090121132337.9ff4ed16.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090117202638.GA11825@us.ibm.com>
	<20090119110906.58ccbcbd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090121030500.GA32138@us.ibm.com>
	<20090121125300.b5916256.kamezawa.hiroyu@jp.fujitsu.com>
	<m1k58pwaxj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757056AbZAUEYz@vger.kernel.org>
In-Reply-To: <m1k58pwaxj.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, oleg@redhat.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, 20 Jan 2009 20:16:40 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > What makes me confused is "Container". There is no "Container" in
> > the linux kernel, just cgroup and its subsyss.
> > (Some source codes still use "cont" but new codes all use "cgroup" or "cgrp" )
> >
> > So, I asked whether "Container" means "Namespace subsys" or something different.
> 
> "Container" is what we use to refer to the user space concept, that is built
> from a set of namespaces and control groups.  A Container that looks like
> a standard linux install from the inside is what we expect the most common
> use of namespaces and control groups to be.
> 

Thank you for clarification :)

Regards,
-Kame

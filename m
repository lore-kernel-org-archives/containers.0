From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was Vpid:)
Date: Thu, 23 Jun 2011 09:37:53 -0500
Message-ID: <20110623143753.GA26914@mail.hallyn.com>
References: <20110615145527.4016.70157.stgit@bahia.local>
 <BANLkTimSC_OSrbekhM=wd2Gie4np3Q4F5A@mail.gmail.com>
 <1308570316.8230.140.camel@bahia.local>
 <BANLkTiknqo0iKry7mjq+mc4iOWj_A_mrrw@mail.gmail.com>
 <m1ei2o9l7a.fsf@fess.ebiederm.org>
 <1308756565.2959.65.camel@bahia.local>
 <m1oc1pl6t1.fsf@fess.ebiederm.org>
 <1308836585.2959.89.camel@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1308836585.2959.89.camel@bahia.local>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Cedric Le Goater <clg@vnet.ibm.com>, linux-kernel@vger.kernel.org, oleg@redhat.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, Bryan Donlan <bdonlan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Greg Kurz (gkurz@fr.ibm.com):
> On Wed, 2011-06-22 at 17:39 -0700, Eric W. Biederman wrote:
> > I was suggesting implement rt_sigqueueinfo_fd as a proc file instead.
> > 
> > Getting a file descriptor api one way or another for delivering signals
> > sounds nice in principle.  I don't know if it is useful enough to
> > justify the cost of implementing and supporting it.
> > 
> 
> That's my concern: it will take some time to work it out and push it. In
> comparison, ActivePid: has no support overhead and is enough for
> userland code to relate pids betwen parent and child namespaces.
> Mitigating the race with pids is cool but it is another topic IMHO.

I think it's perfectly understandable for management / monitoring
software on the host to want to correlate pids on the host and in the
container.    And not reasonable that there is no way to do that.  This
patch makes sense.

I've carelessly deleted patch v3 from my inbox, but Greg please add
my

Acked-by: Serge Hallyn <serge.hallyn@canonical.com>

to v3 (https://lkml.org/lkml/2011/6/22/283)

thanks,
-serge

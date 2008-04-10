From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/3] change clone_flags type to u64
Date: Thu, 10 Apr 2008 12:14:53 -0500
Message-ID: <20080410171453.GA7023@sergelap.ibm.com>
References: <20080409222611.GA28087@us.ibm.com> <20080409223231.GA28267@us.ibm.com> <871w5enmk7.fsf@basil.nowhere.org> <47FE073B.3060007@fr.ibm.com> <20080410125205.GG10019@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757701AbYDJRQm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080410125205.GG10019@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Cedric Le Goater <clg@fr.ibm.com>, sukadev@us.ibm.com, Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Andi Kleen (andi@firstfloor.org):
> > I guess that was a development rationale. 
> 
> But what rationale? It just doesn't make much sense to me.
> 
> > Most of the namespaces are in 
> > use in the container projects like openvz, vserver and probably others 
> > and we needed a way to activate the code.
> 
> You could just have added it to feature groups over time.
> 
> > 
> > Not perfect I agree.
> >  
> > > With your current strategy are you sure that even 64bit will
> > > be enough in the end? For me it rather looks like you'll
> > > go through those quickly too as more and more of the kernel
> > > is namespaced.
> > 
> > well, we're reaching the end. I hope ! devpts is in progress and
> > mq is just waiting for a clone flag.
> 
> Are you sure?

Well for one thing we can take a somewhat different approach to new
clone flags.  I.e. we could extend CLONE_NEWIPC to do mq instead of
introducing a new clone flag.  The name doesn't have 'sysv' in it,
and globbing all ipc resources together makes some amount of sense.
Similarly has hpa+eric pointed out earlier, suka could use
CLONE_NEWDEV for ptys.  If we have net, pid, ipc, devices, that's a
pretty reasonable split imo.  Perhaps we tie user to devices and get
rid of CLONE_NEWUSER which I suspect noone is using atm (since only
Dave has run into the CONFIG_USER_SCHED problem).  Or not.  We could
roll uts into net, and give CLONE_NEWUTS a deprecation period.

-serge

From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 4/5] Move the user namespace under the option
Date: Mon, 1 Oct 2007 09:14:26 -0500
Message-ID: <20071001141426.GB30599@sergelap.austin.ibm.com>
References: <46FA7D4D.8040808@openvz.org> <46FA8087.6060307@openvz.org> <46FBA2A4.2040909@fr.ibm.com> <Pine.LNX.4.64.0709270837220.5275@localhost.localdomain> <4700A7C5.5080005@openvz.org> <Pine.LNX.4.64.0710010440360.12789@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754014AbXJAOOj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710010440360.12789@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Cedric Le Goater <clg@fr.ibm.com>, Andrew Morton <akpm@osdl.org>, Serge Hallyn <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Robert P. J. Day (rpjday@mindspring.com):
> On Mon, 1 Oct 2007, Pavel Emelyanov wrote:
> 
> > Robert P. J. Day wrote:
> > > On Thu, 27 Sep 2007, Cedric Le Goater wrote:
> > >
> > >>> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> > >>> index b5f41d4..dda160c 100644
> > >>> --- a/include/linux/user_namespace.h
> > >>> +++ b/include/linux/user_namespace.h
> > >>> @@ -17,7 +17,7 @@ struct user_namespace {
> > >>>
> > >>>  extern struct user_namespace init_user_ns;
> > >>>
> > >>> -#ifdef CONFIG_USER_NS
> > >>> +#ifdef CONFIG_NAMESPACES_EXPERIMENTAL
> > >
> > > is it really a good precedent to introduce Kconfig variables that
> > > literally include the word "EXPERIMENTAL"?
> >
> > How else can we call it? I proposed one config option for each
> > namespace with "depends on EXPERIMENTAL" dependency, but everyone
> > else said that two options are much better.
> 
> i don't know -- perhaps something as trivially obvious as
> NAMESPACES_V2 or something.  i just think it's awkward to take a word
> like "EXPERIMENTAL" that already has a long and established history,
> and start jamming it into config variable names.  but it's just an
> observation.

But these really are EXPERIMENTAL, not just 'v2'.  They are not yet safe
to use except for testing.  Once they are more complete and safe to use,
they will fall under just CONFIG_NAMESPACES.

-serge

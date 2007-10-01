From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/5] The config option itself
Date: Mon, 1 Oct 2007 09:27:41 -0500
Message-ID: <20071001142741.GC30599@sergelap.austin.ibm.com>
References: <46FA7D4D.8040808@openvz.org> <46FA7E20.80207@openvz.org> <20070926163432.GA23435@sergelap.austin.ibm.com> <20070926170621.GB23435@sergelap.austin.ibm.com> <20070927023024.GA24004@us.ibm.com> <46FB682B.2000100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754661AbXJAO1z@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46FB682B.2000100@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: sukadev@us.ibm.com, "Serge E. Hallyn" <serue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul@openvz.org):
> sukadev@us.ibm.com wrote:
> > Serge E. Hallyn [serue@us.ibm.com] wrote:
> > | Quoting Serge E. Hallyn (serue@us.ibm.com):
> > | > Quoting Pavel Emelyanov (xemul@openvz.org):
> > | > > The option is called NAMESPACES. It can be selectable only
> > | > > if EMBEDDED is chosen (this was Eric's requisition). When
> > | > > the EMBEDDED is off namespaces will be on automatically.
> > | > > 
> > | > > One more option (NAMESPACES_EXPERIMENTAL) was added by 
> > | > > Serge's request to move there all the namespaces that are 
> > | > > not finished yet. Currently only the user and the network
> > | > > namespaces are such.
> > | > > 
> > | > > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> > | > > 
> > | > > ---
> > | > > 
> > | > > diff --git a/init/Kconfig b/init/Kconfig
> > | > > index 684ccfb..05a71d7 100644
> > | > > --- a/init/Kconfig
> > | > > +++ b/init/Kconfig
> > | > > @@ -369,6 +360,23 @@ config RELAY
> > | > > 
> > | > >  	  If unsure, say N.
> > | > > 
> > | > > +config NAMESPACES
> > | > > +	bool "The namespaces support" if EMBEDDED
> > | > > +	default !EMBEDDED
> > | > > +	help
> > | > > +	  Provides the way to make tasks work with different objects using
> > | > > +	  the same id. For example same IPC id may refer to different objects
> > | > > +	  or same user id or pid may refer to different tasks when used in
> > | > > +	  different namespaces.
> > | > > +
> > | > > +config NAMESPACES_EXPERIMENTAL
> > | > > +	bool "Add the experimantal namespaces support" if EMBEDDED
> > | > 
> > | > Hi Pavel,
> > | > 
> > | > Overall this patchset looks good.
> > | > 
> > | > However the NAMESPACES_EXPERIMENTAL option should not have the
> > | > 'if EMBEDDED', right?  This is about EXPERIMENTAL, not about
> > | > EMBEDDED, unlike the plain NAMESPACES option.
> > | > 
> > | > -serge
> > | 
> > | Actually that doesn't seem to work either.  Even though
> > | SECURITY_NAMESPACES=y, the config system seems to infer that
> > | since NAMESPACES is not user-selectable, NAMESPACES_EXPERIMENTAL
> > | shouldn't be either.  So we end up with NAMESPACES_EXPERIMENTAL
> > | being on and not un-selectable if !EMBEDDED.
> > 
> > Yes. Given that NAMESPACES depends on EMBEDDED, NAMESPACES_EXPERIMENTAL
> > can simply depend on NAMESPACES and EXPERIMENTAL with a default of N.
> 
> Nope. The intention is that the NAMESPACES and NAMESPACES_EXPERIMENTAL

No, Eric wanted NAMESPACES to only be unselecteable if EMBEDDED=y, but
NAMESPACES_EXPERIMENTAL should always be unselectable.  If current
config logic can't do that then we should forget about the EMBEDDED
requirement altogether.

The rest of this patchset looks great.  Thanks, Pavel.

-serge

> must not be selectable if EMBEDDED=n, but if we make NS_EXPERIMENTAL
> depend on NAMESPACES only we'll have to make a choice in !EMBEDDED.
> 
> > BTW, does the position of 'config NAMESPACES' in init/Kconfig file
> > matter ?  If it is dependent on EMBEDDED, should it not come later
> > in the file, after 'config EMBEDDED' ?
> > 
> > | 
> > | > > +	depends on NAMESPACES && EXPERIMENTAL
> > | > > +	default !EMBEDDED
> > | > > +	help
> > | > > +	  Also include the support for the namespaces that are not fnished
> > | > > +	  or well developed yet
> > | > > +
> > | > >  config BLK_DEV_INITRD
> > | > >  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
> > | > >  	depends on BROKEN || !FRV
> > | _______________________________________________
> > | Containers mailing list
> > | Containers@lists.linux-foundation.org
> > | https://lists.linux-foundation.org/mailman/listinfo/containers
> > 

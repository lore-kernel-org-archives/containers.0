From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/5] The config option itself
Date: Wed, 26 Sep 2007 12:06:21 -0500
Message-ID: <20070926170621.GB23435@sergelap.austin.ibm.com>
References: <46FA7D4D.8040808@openvz.org> <46FA7E20.80207@openvz.org> <20070926163432.GA23435@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760827AbXIZRGc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070926163432.GA23435@sergelap.austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@osdl.org>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Quoting Pavel Emelyanov (xemul@openvz.org):
> > The option is called NAMESPACES. It can be selectable only
> > if EMBEDDED is chosen (this was Eric's requisition). When
> > the EMBEDDED is off namespaces will be on automatically.
> > 
> > One more option (NAMESPACES_EXPERIMENTAL) was added by 
> > Serge's request to move there all the namespaces that are 
> > not finished yet. Currently only the user and the network
> > namespaces are such.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> > 
> > ---
> > 
> > diff --git a/init/Kconfig b/init/Kconfig
> > index 684ccfb..05a71d7 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -369,6 +360,23 @@ config RELAY
> > 
> >  	  If unsure, say N.
> > 
> > +config NAMESPACES
> > +	bool "The namespaces support" if EMBEDDED
> > +	default !EMBEDDED
> > +	help
> > +	  Provides the way to make tasks work with different objects using
> > +	  the same id. For example same IPC id may refer to different objects
> > +	  or same user id or pid may refer to different tasks when used in
> > +	  different namespaces.
> > +
> > +config NAMESPACES_EXPERIMENTAL
> > +	bool "Add the experimantal namespaces support" if EMBEDDED
> 
> Hi Pavel,
> 
> Overall this patchset looks good.
> 
> However the NAMESPACES_EXPERIMENTAL option should not have the
> 'if EMBEDDED', right?  This is about EXPERIMENTAL, not about
> EMBEDDED, unlike the plain NAMESPACES option.
> 
> -serge

Actually that doesn't seem to work either.  Even though
SECURITY_NAMESPACES=y, the config system seems to infer that
since NAMESPACES is not user-selectable, NAMESPACES_EXPERIMENTAL
shouldn't be either.  So we end up with NAMESPACES_EXPERIMENTAL
being on and not un-selectable if !EMBEDDED.

> > +	depends on NAMESPACES && EXPERIMENTAL
> > +	default !EMBEDDED
> > +	help
> > +	  Also include the support for the namespaces that are not fnished
> > +	  or well developed yet
> > +
> >  config BLK_DEV_INITRD
> >  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
> >  	depends on BROKEN || !FRV

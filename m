From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/5] The config option itself
Date: Thu, 27 Sep 2007 12:22:03 +0400
Message-ID: <46FB682B.2000100@openvz.org>
References: <46FA7D4D.8040808@openvz.org> <46FA7E20.80207@openvz.org>
	<20070926163432.GA23435@sergelap.austin.ibm.com>
	<20070926170621.GB23435@sergelap.austin.ibm.com>
	<20070927023024.GA24004@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070927023024.GA24004-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> | > Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> | > > The option is called NAMESPACES. It can be selectable only
> | > > if EMBEDDED is chosen (this was Eric's requisition). When
> | > > the EMBEDDED is off namespaces will be on automatically.
> | > > 
> | > > One more option (NAMESPACES_EXPERIMENTAL) was added by 
> | > > Serge's request to move there all the namespaces that are 
> | > > not finished yet. Currently only the user and the network
> | > > namespaces are such.
> | > > 
> | > > Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> | > > 
> | > > ---
> | > > 
> | > > diff --git a/init/Kconfig b/init/Kconfig
> | > > index 684ccfb..05a71d7 100644
> | > > --- a/init/Kconfig
> | > > +++ b/init/Kconfig
> | > > @@ -369,6 +360,23 @@ config RELAY
> | > > 
> | > >  	  If unsure, say N.
> | > > 
> | > > +config NAMESPACES
> | > > +	bool "The namespaces support" if EMBEDDED
> | > > +	default !EMBEDDED
> | > > +	help
> | > > +	  Provides the way to make tasks work with different objects using
> | > > +	  the same id. For example same IPC id may refer to different objects
> | > > +	  or same user id or pid may refer to different tasks when used in
> | > > +	  different namespaces.
> | > > +
> | > > +config NAMESPACES_EXPERIMENTAL
> | > > +	bool "Add the experimantal namespaces support" if EMBEDDED
> | > 
> | > Hi Pavel,
> | > 
> | > Overall this patchset looks good.
> | > 
> | > However the NAMESPACES_EXPERIMENTAL option should not have the
> | > 'if EMBEDDED', right?  This is about EXPERIMENTAL, not about
> | > EMBEDDED, unlike the plain NAMESPACES option.
> | > 
> | > -serge
> | 
> | Actually that doesn't seem to work either.  Even though
> | SECURITY_NAMESPACES=y, the config system seems to infer that
> | since NAMESPACES is not user-selectable, NAMESPACES_EXPERIMENTAL
> | shouldn't be either.  So we end up with NAMESPACES_EXPERIMENTAL
> | being on and not un-selectable if !EMBEDDED.
> 
> Yes. Given that NAMESPACES depends on EMBEDDED, NAMESPACES_EXPERIMENTAL
> can simply depend on NAMESPACES and EXPERIMENTAL with a default of N.

Nope. The intention is that the NAMESPACES and NAMESPACES_EXPERIMENTAL
must not be selectable if EMBEDDED=n, but if we make NS_EXPERIMENTAL
depend on NAMESPACES only we'll have to make a choice in !EMBEDDED.

> BTW, does the position of 'config NAMESPACES' in init/Kconfig file
> matter ?  If it is dependent on EMBEDDED, should it not come later
> in the file, after 'config EMBEDDED' ?
> 
> | 
> | > > +	depends on NAMESPACES && EXPERIMENTAL
> | > > +	default !EMBEDDED
> | > > +	help
> | > > +	  Also include the support for the namespaces that are not fnished
> | > > +	  or well developed yet
> | > > +
> | > >  config BLK_DEV_INITRD
> | > >  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
> | > >  	depends on BROKEN || !FRV
> | _______________________________________________
> | Containers mailing list
> | Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> | https://lists.linux-foundation.org/mailman/listinfo/containers
> 

From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 20:02:33 -0500
Message-ID: <1231290153.11487.34.camel@heimdal.trondhjem.org>
References: <ae2fa56f38f87da3a90ab6fe39954b2b.squirrel@webmail.uio.no>
	 <1231289847.14345.243.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1231289847.14345.243.camel@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-01-06 at 16:57 -0800, Matt Helsley wrote:
> On Tue, 2009-01-06 at 19:39 -0500, trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org wrote:
> > On Tue, 2009-01-06 at 16:08 -0800, Matt Helsley wrote:
> > > IMHO This seems more incorrect than trying to use a more proximal
> > namespace.
> > 
> > You have yet to explain why.
> 
> Yes, I know I have to explain why. If you would please have a little
> more patience you might see I have replied to your original request for
> an explanation -- I *just* sent it out. If I don't see it show up soon
> I'll resend it as a reply here. OK?

Sorry if you saw the request twice. My mail server at uio.no appears to
be on the blink, so I switched to the netapp account...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] cgroups: implement device whitelist lsm (v3)
Date: Mon, 17 Mar 2008 23:48:42 -0700
Message-ID: <20080318064842.GA23167@kroah.com>
References: <176755.88432.qm@web36612.mail.mud.yahoo.com> <1205760399.22912.183.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753160AbYCRGsx@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1205760399.22912.183.camel@moss-spartans.epoch.ncsc.mil>
Sender: linux-kernel-owner@vger.kernel.org
To: Stephen Smalley <sds@epoch.ncsc.mil>
Cc: casey@schaufler-ca.com, "Serge E. Hallyn" <serue@us.ibm.com>, James Morris <jmorris@namei.org>, lkml <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 17, 2008 at 09:26:39AM -0400, Stephen Smalley wrote:
> > > The original promise was that LSM would allow kernels to be built that
> > > shed capabilities altogether,
> > 
> > I don't remember that, but it's been a long time so it could be true.
> 
> "One of the explicit requirements to get LSM into the kernel was to have
> the ability to make capabilities be a module.  This allows the embedded
> people to completely remove capabilities, as they really want this.  I
> don't think we can ignore this, no matter how much of a pain in the butt
> it is :)" - Greg KH
> 
> Quoted from:
> http://marc.info/?l=linux-security-module&m=99236500727804&w=2
> 
> Ironically, since that time, capabilities have doubled in size and still
> can't be removed from the core kernel since LSM didn't push the state
> into the security blobs.

Maybe we need to seriously revisit this and perhaps rip capabilities
back out and put it always into the kernel if it's always a requirement.

Comments made 7 years ago might be totally wrong when we have now
learned how this all has worked out...

thanks,

greg k-h

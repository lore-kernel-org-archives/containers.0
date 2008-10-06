From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/3] user namespaces: introduce user_struct->user_namespace
 relationship
Date: Tue, 7 Oct 2008 08:50:15 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0810070847480.4113@tundra.namei.org>
References: <20081004013644.GA24104@us.ibm.com> <alpine.LRH.1.10.0810060846020.30516@tundra.namei.org> <20081006141101.GB15419@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755981AbYJFVv6@vger.kernel.org>
In-Reply-To: <20081006141101.GB15419@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Mon, 6 Oct 2008, Serge E. Hallyn wrote:

> Quoting James Morris (jmorris@namei.org):
> > On Fri, 3 Oct 2008, Serge E. Hallyn wrote:
> > 
> > > Hi James,
> > > 
> > > here are 3 patches to fix up the user namespaces a bit in preparation
> > > for real userns work to begin.  Andrew had suggested that these be
> > > rebased on top of your -next tree because they will conflict with
> > > the credentials work.  But it looks like much of the credentials stuff
> > > isn't in your next branch.  If you'd prefer that I port these to
> > > creds-next, please let me know.  I'll have to do it eventually :)
> > 
> > creds-next is dead.
> > 
> > Code ready for the next merge window is in the 'next' branch, while the 
> > current creds code is in the 'creds-next-subsys' branch, which hasn't been 
> > picked up in linux-next yet because of LPC and sfr's vacation.
> > 
> > When do you expect these patches to be sent upstream?  Are they ready now 
> > as an incremental change for 2.6.27?
> 
> Oh I'm not trying to get them into 2.6.28, I'm just trying to get them
> more widely tested, hopefully aiming for 2.6.29.  They have been stable
> in all of my tests, and the last patch fixes a real (behavioral - not
> oops-inducing) bug in the current code, but I'm trying to figure out
> which path they should take.

I suggest feeding them into linux-next directly until you want them merged 
with another tree.  Are there known clashes with the creds work?  If so, 
the fixups could be carried in linux-next, or generate them against 
creds-next-subsys for inclusion after that.

-- 
James Morris
<jmorris@namei.org>

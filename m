From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/2] Extend sys_clone and sys_unshare system calls API
Date: Thu, 17 Jan 2008 03:48:44 +0000
Message-ID: <20080117034844.GA27894@ZenIV.linux.org.uk>
References: <478DFF8F.9030006@openvz.org> <9803.1200493420@vena.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754552AbYAQDs7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9803.1200493420@vena.lwn.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Cedric Le Goater <clg@fr.ibm.com>, drepper@redhat.com, Serge Hallyn <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Wed, Jan 16, 2008 at 07:23:40AM -0700, Jonathan Corbet wrote:
> Hi, Pavel,
> 
> [Adding Ulrich]
> 
> > I use the last bit in the clone_flags for CLONE_LONGARG. When set it
> > will denote that the child_tidptr is not a pointer to a tid storage,
> > but the pointer to the struct long_clone_struct which currently 
> > looks like this:
> 
> I'm probably just totally off the deep end, but something did occur to
> me: this looks an awful lot like a special version of the sys_indirect()
> idea.  Unless it has been somehow decided that sys_indirect() is the
> wrong idea, might it not be better to look at making that interface
> solve the extended clone() problem as well?

Nah, just put an XML parser into the kernel to have the form match the
contents...

Al "perhaps we should newgroup alt.tasteless.api for all that stuff" Viro

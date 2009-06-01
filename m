From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 8/9] user namespaces: debug refcounts
Date: Mon, 1 Jun 2009 14:02:50 -0500
Message-ID: <20090601190250.GA19649@hallyn.com>
References: <20090529223229.GA14536@us.ibm.com> <20090529223352.GH14602@us.ibm.com> <20090531185113.GA13675@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090531185113.GA13675@x200.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, Andrew Morgan <morgan@kernel.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan@gmail.com):
> On Fri, May 29, 2009 at 05:33:52PM -0500, Serge E. Hallyn wrote:
> > Create /proc/userns, which prints out all user namespaces.  It
> > prints the address of the user_ns itself, the uid and userns address
> > of the user who created it, and the reference count.
> 
> > +static int proc_userns_show(struct seq_file *m, void *v)
> > +{
> > +	struct user_namespace *ns = v;
> > +	seq_printf(m, "userns %p creator (uid %d ns %p) count %d\n",
> > +		(void *)ns, ns->creator->uid, (void *) ns->creator->user_ns,
> > +		atomic_read(&ns->kref.refcount));
> > +	return 0;
> > +}
> 
> Kernel shouldn't expose location of kernel objects to userspace.

This one was just so ppl could verify things were working as
promised.  I won't be sending it again.

(OTOH, noone noticed i wasn't actually calling the securebits
c/r helpers...  I'll be sending a new set of patches fixing that,
not including this patch, and hopefully addressing Andrew's and
Oren's latest replies.

thanks,
-serge

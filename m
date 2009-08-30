From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 3/5] cr: add generic LSM c/r support
Date: Sun, 30 Aug 2009 15:26:43 -0500
Message-ID: <20090830202643.GB16222@hallyn.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210417.GC28048@us.ibm.com> <4A98AEDE.1000105@schaufler-ca.com> <20090829224147.GA12549@hallyn.com> <4A99BC58.9040205@schaufler-ca.com> <20090830135800.GC14699@hallyn.com> <4A9ACD0A.9050004@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A9ACD0A.9050004@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey@schaufler-ca.com):
> Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey@schaufler-ca.com):
> > I know, I know,  I should come up with a better name.  But while
> > an selinux context would be
> >
> >   root_u:root_r:root_t
> >
> > the blob I have to checkpoint for a task would perhaps be
> >
> >   root_u:root_r:root_t:::null:::null::null:::user_u:serge_r:serge_t:::null
> >   
> 
> What you really want is a textual representation of the security blob
> if I read this correctly.

Exactly.

>  Seems like you could call this either a
> "blob string" or a "context collection" or a "checkpoint string".

Object security state?  "Foss" for full object security state?

I suspect I'll default to blob...

-serge

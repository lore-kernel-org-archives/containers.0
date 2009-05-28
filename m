From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 6/8] cr: checkpoint and restore task credentials
Date: Thu, 28 May 2009 18:36:10 +0400
Message-ID: <20090528143610.GA18256@x200.localdomain>
References: <20090526173242.GA13757@us.ibm.com> <20090526173354.GF13991@us.ibm.com> <20090527183610.GA31930@x200.localdomain> <20090528140110.GA772@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090528140110.GA772@hallyn.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

On Thu, May 28, 2009 at 09:01:10AM -0500, Serge E. Hallyn wrote:
> Quoting Alexey Dobriyan (adobriyan@gmail.com):
> > On Tue, May 26, 2009 at 12:33:54PM -0500, Serge E. Hallyn wrote:
> > > +struct ckpt_hdr_cred {
> > > +	struct ckpt_hdr h;
> > > +	__u32 version; /* especially since capability sets might grow */
> > 
> > Oh, no. Image version should be incremented.
> 
> Why?  The format hasn't changed since my last set I don't think...
> 
> Oh, I added the padding.  Thanks.  I have to bump it again for the
> next set (hopefully out today or tomorrow) as it adds securebits.
> (And hopefully a first stab at LSM, though it's not looking
> likely)

Well, formally format has changed.

But the statement is that image version alone is enough so
per-object image versions aren't necessary.

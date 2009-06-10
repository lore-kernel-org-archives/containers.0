From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 04/10] cr: split core function out of some set*{u,g}id
	functions
Date: Wed, 10 Jun 2009 07:51:45 -0500
Message-ID: <20090610125145.GA12204@us.ibm.com>
References: <20090610014412.GA5628@us.ibm.com> <20090610014456.GC5658@us.ibm.com> <alpine.LRH.2.00.0906102219230.24923@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.0906102219230.24923@tundra.namei.org>
Sender: linux-security-module-owner@vger.kernel.org
To: James Morris <jmorris@namei.org>
Cc: Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morgan <morgan@kernel.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting James Morris (jmorris@namei.org):
> On Tue, 9 Jun 2009, Serge E. Hallyn wrote:
> 
> > When restarting tasks, we want to be able to change xuid and
> > xgid in a struct cred, and do so with security checks.  Break
> > the core functionality of set{fs,res}{u,g}id into cred_setX
> > which performs the access checks based on current_cred(),
> > but performs the requested change on a passed-in cred.
> > 
> 
> Please cc the lsm list when making changes to security.

Argh, they were cc:d on my last version, and I was sure I'd
put them in the list of headers for this set.

FWIW, the thread can be seen here
https://lists.linux-foundation.org/pipermail/containers/2009-June/018509.html

thanks,
-serge

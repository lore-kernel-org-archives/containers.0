From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] cr: lsm: restore LSM contexts for ipc objects
Date: Mon, 22 Jun 2009 15:37:45 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0906221537190.19585@tundra.namei.org>
References: <20090620013216.GA4435@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090620013216.GA4435@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Stephen Smalley <sds@epoch.ncsc.mil>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

On Fri, 19 Jun 2009, Serge E. Hallyn wrote:

> Here is the next version of the patch implementing checkpoint
> and restore of LSM contexts.  This is just handling IPC objects
> as a proof of concept.  But actually, looking ahead and both
> files and tasks, I see that selinux stores several sids in the
> security structs.  For instance, for tasks there is the current
> sid, exec sid, create sid, keycreate_sid, and sockcreate_sid.
> So I guess I'll have to ask the LSM for how many secids it wants
> to checkpoint, then checkpoint an array of contexts?
> 

Can you please explain exactly what checkpoint/restart is?

-- 
James Morris
<jmorris@namei.org>

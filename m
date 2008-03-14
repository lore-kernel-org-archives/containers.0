From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] cgroups: implement device whitelist lsm (v3)
Date: Fri, 14 Mar 2008 21:17:12 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0803142039460.32184@us.intercode.com.au>
References: <20080313144142.GB11265@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080313144142.GB11265@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Casey Schaufler <casey@schaufler-ca.com>, Greg KH <greg@kroah.com>, Pavel Emelianov <xemul@openvz.org>, Stephen Smalley <sds@epoch.ncsc.mil>
List-Id: containers.vger.kernel.org

On Thu, 13 Mar 2008, Serge E. Hallyn wrote:

> Implement a cgroup using the LSM interface to enforce open and mknod
> on device files.

Actually, I'm not sure that the LSM approach in general is best here.

The LSM model is that standard DAC logic lives in the core kernel, and 
that extended security logic (e.g. MAC) is called after DAC via hooks.  
cgroups has introduced new security logic of its own, which is arguably 
"standard DAC" when cgroups is enabled.

I can understand Greg not wanting this security logic in the core kernel, 
but it is specific to cgroups (which itself is security model agnostic) 
and does not stand alone as a distinct security framework.

The fact that all existing LSMs need to invoke exactly the same code is an 
indicator that it doesn't belong in LSM.

Moving this logic into LSM means that instead of the cgroups security 
logic being called from one place in the main kernel (where cgroups 
lives), it must be called identically from each LSM (none of which are 
even aware of cgroups), which I think is pretty obviously the wrong 
solution.

This is baggage which comes with cgroups -- please don't push it into LSM 
to try and hide that.


- James
-- 
James Morris
<jmorris@namei.org>

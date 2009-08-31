From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add
	RESTART_KEEP_LSM flag
Date: Mon, 31 Aug 2009 08:36:56 -0500
Message-ID: <20090831133656.GC4837@us.ibm.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210208.GA28048@us.ibm.com> <4A98B1D7.9050108@schaufler-ca.com> <20090829225923.GB12549@hallyn.com> <4A99C1B6.6080504@schaufler-ca.com> <20090830134809.GA14699@hallyn.com> <4A9ACBD4.4020804@schaufler-ca.com> <20090830202412.GA16222@hallyn.com> <4A9AF28D.2030803@schaufler-ca.com> <20090831132258.GB4837@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090831132258.GB4837@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Quoting Casey Schaufler (casey@schaufler-ca.com):
> > Serge E. Hallyn wrote:
> > > Quoting Casey Schaufler (casey@schaufler-ca.com):
> > > So do you think that adding a policy version check in the kernel
> > > at restart would help this?
> 
> For the moment I intend to add a patch on top of these adding two
> security calls:
> 
> 	security_may_checkpoint(ctx) which will authorize the
> 		ability to checkpoint at all, and

I meant:

	security_may_restore(ctx).

-serge

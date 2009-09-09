From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] cr: debug security_checkpoint_header and
	security_may_restart
Date: Wed, 9 Sep 2009 09:35:42 -0500
Message-ID: <20090909143542.GA23322@us.ibm.com>
References: <20090903222824.GB27377@us.ibm.com> <20090903222853.GA27556@us.ibm.com> <4AA0A3AE.9040106@schaufler-ca.com> <20090904134611.GA11508@us.ibm.com> <4AA55183.4020407@schaufler-ca.com> <20090908041221.GB25161@us.ibm.com> <4AA73278.4030301@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AA73278.4030301@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey@schaufler-ca.com):
> Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey@schaufler-ca.com):
> > Sorry, the c/r tree is at:
> >
> > git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
> >   
> 
> The four patches from 08/28 (2-5) and the two from 09/03
> are not happy applying to this tree. Am I missing a patch?
> 

There was this patch which was 1/5
	https://lists.linux-foundation.org/pipermail/containers/2009-August/020212.html

But there have also been some changes since that posting to the
git tree.  You could rewind the git tree to the state it was in
on aug 28, but I'll need to forward-port my patches anyway, so
let me do that this afternoon and resend the patchset.

-serge

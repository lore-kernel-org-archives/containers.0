From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/1] cr: lsm: restore LSM contexts for ipc objects
Date: Thu, 25 Jun 2009 07:59:36 -0500
Message-ID: <20090625125936.GA30349@us.ibm.com>
References: <20090620013216.GA4435@us.ibm.com> <1245779751.27538.14.camel@localhost.localdomain> <20090623181810.GA23644@us.ibm.com> <20090623195703.GA25469@us.ibm.com> <1245849008.9669.13.camel@moss-pluto.epoch.ncsc.mil> <20090624220736.GA21134@us.ibm.com> <1245933275.9669.100.camel@moss-pluto.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1245933275.9669.100.camel@moss-pluto.epoch.ncsc.mil>
Sender: linux-security-module-owner@vger.kernel.org
To: Stephen Smalley <sds@epoch.ncsc.mil>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

Quoting Stephen Smalley (sds@epoch.ncsc.mil):
> On Wed, 2009-06-24 at 17:07 -0500, Serge E. Hallyn wrote:
> > Oh, no.  I wasn't thinking right.
> > 
> > The objects are actually restored through calls to do_shmget() etc,
> > so that security_xyz_alloc() already gets called.
> 
> Does this mean that the objects temporarily exist in the wrong security
> context and are accessible to other threads during the interval between
> creation and when they get "restored" to the right security context?

They get restored in a private IPC namespace so they aren't accessible
to any live tasks.  Also, the objects will be created using the default
context for the program doing sys_restore(), running as app_restore_t or
something, so presumably a policy could ensure that such temporary
objects aren't readable by anyone else, just in case something goes
wrong before the security_ipcxyz_restore(), right?

-serge

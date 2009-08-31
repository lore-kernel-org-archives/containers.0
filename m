From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add
	RESTART_KEEP_LSM flag
Date: Mon, 31 Aug 2009 08:22:58 -0500
Message-ID: <20090831132258.GB4837@us.ibm.com>
References: <20090828210041.GA27878@us.ibm.com> <20090828210208.GA28048@us.ibm.com> <4A98B1D7.9050108@schaufler-ca.com> <20090829225923.GB12549@hallyn.com> <4A99C1B6.6080504@schaufler-ca.com> <20090830134809.GA14699@hallyn.com> <4A9ACBD4.4020804@schaufler-ca.com> <20090830202412.GA16222@hallyn.com> <4A9AF28D.2030803@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A9AF28D.2030803@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, Stephen Smalley <sds@epoch.ncsc.mil>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey@schaufler-ca.com):
> Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey@schaufler-ca.com):
> > So do you think that adding a policy version check in the kernel
> > at restart would help this?

For the moment I intend to add a patch on top of these adding two
security calls:

	security_may_checkpoint(ctx) which will authorize the
		ability to checkpoint at all, and
	security_write_checkpoint_hdr(ctx) will for now do nothing
		in any lsm, but will reserve a spot in the checkpoint
		header for an lsm-defined blob to write some policy
		info if it wants (i.e. a sha1sum of the policy).
		This way if it is decided that selinux or smack wants
		to do that, we won't need a change of the policy
		format.

> > Do you think providing a recipe for userspace to do the policy
> > checks would help?
> 
> If you are willing to trust the user space tools to get it right.
> It gets things really complicated building trust relationships when
> you have multiple policies to deal with. Look at the issues that
> labeled NFS is trying to deal with. How would the user space program
> know what the policy may have been when the process last ran?

It could query the lsm somehow (cat /smack/load | sha1sum?) and
store the result in a file sitting next to the checkpoint image.

Or, if we implement security_write_checkpoint_hdr() above, then
it could simply read the info out of the checkpoint file itself.

As for trusting user space tools to get it right, as it is
user space tools are required to get file labeling and policy
loads right.  So if we have the above two hooks, then selinux
could forbid any domain but restore_t from doing a sys_restart()
where the only program allowed to enter into restore_t does a
check for valid policy.  And/or, it could check at security_may_checkpoint()
to make sure that the context file is of type checkpoint_file_t,
where only an admin-approved /bin/checkpoint of type checkpoint_t
is allowed to create or write to files of type checkpoint_file_t.

> >   Along with a security_may_restart() hook
> > so that LSM policy can force restart to go through a helper
> > that does these checks, if it wants to enforce that?
> >   
> 
> 
> I really don't know. As you're well aware, I've never bought
> into the sophistication of the SELinux policy mechanism. One
> of my major concerns has always been that the policy on two
> machines may be different. With CR you have a case where the
> policy on the same machine can be different over the life of
> a process.

Right, or you can just consider it migrating to a different
machine, where the different machine could be the same machine
after a lot of system and policy updates.

> I am much less concerned with Smack because all the protection
> it provides are subject/object relationships and those are
> pretty straight forward. Even there, if the old rule set allowed
> the process to read from a label the new rule set doesn't allow
> you could get burned.
> 
> In the end, I don't suppose that anything stronger than "requires
> privilege" is going to result in a system that's useful. So maybe
> your best bet is security_may_restart(), and let the LSM decide.
> Smack will most likely require CAP_MAC_ADMIN where as SELinux will
> do a check based on the half-dozen contexts mentioned elsewhere.
> I still don't think it is safe, but upon further reflection I'm
> convinced that from a security standpoint it can never be safe to
> do a restore. So we're debating one case, and a fringe one at that.
> 
> Let 'er rip.

:)

thanks,
-serge

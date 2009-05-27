From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 0/8] a start to credentials c/r
Date: Wed, 27 May 2009 13:24:32 -0500
Message-ID: <20090527182432.GE780@us.ibm.com>
References: <20090526173242.GA13757@us.ibm.com> <4A1CAE03.7090005@schaufler-ca.com> <20090527123728.GA27160@us.ibm.com> <4A1D6449.4020906@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A1D6449.4020906@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey@schaufler-ca.com):
> Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey@schaufler-ca.com):
...
> > Uh, so yes, bsaed on info in the file as well  :)  Except
> > of course the LSM would just be fed the checkpointed context
> > and the checkpoint file context (and can deduce current's context).
> >   
> 
> And SELinux can do whatever calculations it likes based on the
> three contexts and the loaded policy.  Are you at all concerned
> about the possibility that the policy may have changed? I can
> envision scenarios in which it would be impossible for a process
> to gain a particular context under current policy, but that a
> checkpointed process may have stored away.

Good point.  But on the other hand, if the program were running
the whole time, instead of being checkpointed and restarted, then
the running program wouldn't be relabeled when the policy changed,
right?  Now if the domain becomes invalid, then presumably the
restart would fail.  But if the (source_domain,entry_type)->new_domain
set changes from (root_t,x_entry_t)->x_t to (root_t,x_entry_t)->y_t,
a task running as x_t won't be relabeled to y_t.  So I don't thnk
restarting a task which is checkpointed as x_t, under the x_t
domain, is wrong.

> >>>  and one which determines
> >>> the task->cred->security filed based upon any of:
> >>> 	1. current_security() of the task calling sys_restart()
> >>> 	2. the task->cred->security checkpointed in the ckpt file
> >>> 	3. the ->security of the checkpoint file
> >>>   
> >>>       
> >> For Smack the correct behavior would be:
> >>
> >>     1. for sys_restart() callers without CAP_MAC_ADMIN
> >>     2. for sys_restart() callers with CAP_MAC_ADMIN
> >>     3. never
> >>     
> >
> > That makes sense, and is basically analagous (if I'm thinking
> > right) to how I'm doing capabilities.
> >
> > So the first (authorization hook) for smack would just always
> > return TRUE?
> >   
> 
> I suggest that it needs to check for a valid Smack label. Even though
> they're just text strings they do have limitations, including size
> (> 0 < 24) and character set. A call to smk_import() is the right
> way to do it, as it also makes sure the label is in the internal list.
> If smk_import() returns NULL something's amiss.

Ok, thanks.

-serge

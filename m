From: Shaya Potter <spotter@cs.columbia.edu>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add RESTART_KEEP_LSM
 flag
Date: Wed, 02 Sep 2009 14:55:22 -0400
Message-ID: <4A9EBF9A.1070508@cs.columbia.edu>
References: <20090828210041.GA27878@us.ibm.com> <20090830134809.GA14699@hallyn.com> <4A9ACBD4.4020804@schaufler-ca.com> <200909012229.48973.russell@coker.com.au> <4A9E9F14.2010103@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4A9E9F14.2010103@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: russell@coker.com.au, "Serge E. Hallyn" <serge@hallyn.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>
List-Id: containers.vger.kernel.org

Casey Schaufler wrote:
> 
> Checkpoint/restart has traditionally been interesting in the
> mainframe and supercomputer space. These environments have very
> different security profiles from a user desktop. No one at the
> [.......] National Supercomputer Centre cares if you can save
> your rogue game as soon as you pick up the Amulet of Yendor and
> restart it if you get killed on the way up. These environments
> are concerned with leaking data between the groups that have
> funded the facility, which is why they are very often customers
> of advanced access control technologies. I don't know that I see
> a really good security story for C/R in the desktop space, and
> as Russell points out, there are plenty of opportunities to
> exploit the feature. This is of course well outside the scope of
> what goes on within an LSM, where the specific issues are more
> or less contained.

#1 I think you are shortsighted on this, there are many desktop
scenarios where c/r has benefits.  Think linux terminal services, where
one has a large amount of backend machines and doesn't want to kill a
user's session due to having to reboot a machine, or to do load balancing.

#2 I think all this discussion is making things more complicated than it
needs to be.

There should be a simple policy decision.

Q. Would we allow this "user" (of the restart mechanism) to create a
container and be root to it.

If the answer is yes, then any restart (even with a maliciously modified
checkpoint file) should be allowed to proceed, as no differences between
that and what it could do anyways.

If the answer is no, then any restart should not be allowed to proceed.

why?  I imagine restart working something like this

a) create new container for restarted processes
b) restore processes
c) apply container LSM policy
d) let processes run

why in this order, for the reasoning given before that permissions can
change.  This can actually be an issue with just a single user if you
try to restore as that single user

i.e.
touch a
open(a)
chmod 000 a

and now try to restart, so shows the reliance on "root" in the context
of the new container.  its also possible to argue that if one does
security model changes such as this, restart should fail, and therfore
could switch by b/c above.

now getting back to the why.

what are the 2 primary attacks that have been mentioned

1) total host security policy
2) maliciously created checkpoint files

for #2, if we apply the policy decision I stated above, we shouldn't
care about malicious checkpoint files (beyond their ability to trigger
kernel bugs), as there's no fundamental difference between what a
malicious user could do with a constructed checkpoint file and what our
policy decision is based on (being root to the container).

for #1, why should this manner?  if host policy (say re network
connections?) would prevent some sort of functionality, this should
cause restart to error out with a security permission error.  restart
shouldn't ignore host policy in this case.   Though I would add, this
shouldn't really matter re file system, as each containers fs should be
isolated, and if they are shared and have different rules on different
machines, I believe you have a much bigger fundamental security problem.

This then makes restart just an issue of how LSM policies can actually
operate with multiple different containers that should be treated as
fully independent machines running on a single host and with possibly
different security requirements for each container, but not a
checkpoint/restart issue in specific.

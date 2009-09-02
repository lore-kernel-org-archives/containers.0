From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add RESTART_KEEP_LSM
 flag
Date: Wed, 02 Sep 2009 15:27:44 -0700
Message-ID: <4A9EF15F.1080803@schaufler-ca.com>
References: <20090828210041.GA27878@us.ibm.com> <20090830134809.GA14699@hallyn.com> <4A9ACBD4.4020804@schaufler-ca.com> <200909012229.48973.russell@coker.com.au> <4A9E9F14.2010103@schaufler-ca.com> <4A9EBF9A.1070508@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4A9EBF9A.1070508@cs.columbia.edu>
Sender: linux-security-module-owner@vger.kernel.org
To: Shaya Potter <spotter@cs.columbia.edu>
Cc: russell@coker.com.au, "Serge E. Hallyn" <serge@hallyn.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>
List-Id: containers.vger.kernel.org

Shaya Potter wrote:
> Casey Schaufler wrote:
>   
>> Checkpoint/restart has traditionally been interesting in the
>> mainframe and supercomputer space. These environments have very
>> different security profiles from a user desktop. No one at the
>> [.......] National Supercomputer Centre cares if you can save
>> your rogue game as soon as you pick up the Amulet of Yendor and
>> restart it if you get killed on the way up. These environments
>> are concerned with leaking data between the groups that have
>> funded the facility, which is why they are very often customers
>> of advanced access control technologies. I don't know that I see
>> a really good security story for C/R in the desktop space, and
>> as Russell points out, there are plenty of opportunities to
>> exploit the feature. This is of course well outside the scope of
>> what goes on within an LSM, where the specific issues are more
>> or less contained.
>>     
>
> #1 I think you are shortsighted on this, there are many desktop
> scenarios where c/r has benefits.

I did not say there were not. I pointed out that historically C/R
has been used in the realm of mainframes and supercomputers. Because
it was developed in that space, the design reflects the needs of
that space. There are plenty of uses for C/R in a desktop environment.
The question is which of those constitute use, misuse, and abuse.

>   Think linux terminal services, where
> one has a large amount of backend machines and doesn't want to kill a
> user's session due to having to reboot a machine, or to do load balancing.
>   

I hesitate to point out that this is hardly a desktop application.

> #2 I think all this discussion is making things more complicated than it
> needs to be.
>   

Linux is more complicated than it needs to be. (smiley here)
Often for good reasons, but ...

> There should be a simple policy decision.
>
> Q. Would we allow this "user" (of the restart mechanism) to create a
> container and be root to it.
>
> If the answer is yes, then any restart (even with a maliciously modified
> checkpoint file) should be allowed to proceed, as no differences between
> that and what it could do anyways.
>
> If the answer is no, then any restart should not be allowed to proceed.
>   

Oh my, but you've introduced a lot of complexity. Requiring container
management is going to put the feature well out of reach of your
typical desktop user. And most importantly, how are "we" supposed to
figure out whether or not "we" would allow that? I know lots of
people who would allow C/R without blinking, and others who will only
allow it if you can demonstrate that the security state of the system
is unchanged between C and R, and  that the re-introduction of the
process will not affect the security state of the system. Goodness,
I suspect that getting Stephen and myself to agree on what would be
right for a system without an LSM would be close to impossible.

> why?  I imagine restart working something like this
>
> a) create new container for restarted processes
> b) restore processes
> c) apply container LSM policy
> d) let processes run
>
> why in this order, for the reasoning given before that permissions can
> change.  This can actually be an issue with just a single user if you
> try to restore as that single user
>
> i.e.
> touch a
> open(a)
> chmod 000 a
>
> and now try to restart, so shows the reliance on "root" in the context
> of the new container.  its also possible to argue that if one does
> security model changes such as this, restart should fail, and therfore
> could switch by b/c above.
>
> now getting back to the why.
>
> what are the 2 primary attacks that have been mentioned
>
> 1) total host security policy
> 2) maliciously created checkpoint files
>
> for #2, if we apply the policy decision I stated above, we shouldn't
> care about malicious checkpoint files (beyond their ability to trigger
> kernel bugs), as there's no fundamental difference between what a
> malicious user could do with a constructed checkpoint file and what our
> policy decision is based on (being root to the container).
>   

That's sort of throwing the puppy under the bus. You say that you
have to trust it as if it came from a stone tablet handed to you
by a burning bush, so if you don't trust it that much, don't do it.
This is very much the supercomputer mindset, and they use all sorts
of interesting techniques, including seriously restricted access, to
make that viable. It makes the feature unusable in the typical case.

> for #1, why should this manner?  if host policy (say re network
> connections?) would prevent some sort of functionality, this should
> cause restart to error out with a security permission error.  restart
> shouldn't ignore host policy in this case.   Though I would add, this
> shouldn't really matter re file system, as each containers fs should be
> isolated, and if they are shared and have different rules on different
> machines, I believe you have a much bigger fundamental security problem.
>
>   

File systems are lower risk, true enough, because their access policies
are pretty simple. The complex interactions between independently
defined application policies (I gave you a cookie two weeks ago when
I liked you, and now I don't, but you can use the cookie because even
though I disowned you and killed all your old processes, you can get
at my special resource because you restarted a checkpointed process.)
are going to give you grief.

> This then makes restart just an issue of how LSM policies can actually
> operate with multiple different containers that should be treated as
> fully independent machines running on a single host and with possibly
> different security requirements for each container, but not a
> checkpoint/restart issue in specific.
>
>   

Multiple containers are no more viable a solution than type enforcement,
simple separation, Bell & LaPadula or multiple virtual machines for the
general case. You have fallen into the isolation fallacy. Isolation is
easy, sharing is hard, and you don't have a restart if you can't share
the resources from before.

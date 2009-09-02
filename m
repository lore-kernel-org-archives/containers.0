From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and add RESTART_KEEP_LSM
 flag
Date: Wed, 02 Sep 2009 09:36:36 -0700
Message-ID: <4A9E9F14.2010103@schaufler-ca.com>
References: <20090828210041.GA27878@us.ibm.com> <20090830134809.GA14699@hallyn.com> <4A9ACBD4.4020804@schaufler-ca.com> <200909012229.48973.russell@coker.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200909012229.48973.russell@coker.com.au>
Sender: linux-security-module-owner@vger.kernel.org
To: russell@coker.com.au
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, "Eric W. Biederman" <ebiederm@xmission.com>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>
List-Id: containers.vger.kernel.org

Russell Coker wrote:
> On Mon, 31 Aug 2009, Casey Schaufler <casey@schaufler-ca.com> wrote:
>   
>> I seem to be having some trouble presenting my point. It's not about
>> the passwords. It's not about the firewall configuration. It's not
>> even really about the SELinux policy. It's about the total security
>> configuration of the system. This is a problem with checkpoint/restart
>> in general and there isn't much we can do about reassigning user id
>> and other bad things that can happen.
>>
>> If the admin decides that an action is acceptable because the SELinux
>> policy prevents some other action it had better be the case that a
>> process was never allowed to perform that "other action". If you allow
>> restart across policy changes you can't be sure that the process has
>> not performed such an "other action". Processes are not stateless.
>>     
>
> Of course we potentially have the same issue when changing a boolean, and when 
> loading a new policy on a running system.  In a realistic scenario, if you 
> make a change that allows a process context to write to a public data store 
> while at the same time denying read access to secret data then you also need 
> to purge the contents of any files that the process may open for read/write.
>
> Similar problems can also occur using Unix permissions and certain 
> combinations of chmod with setuid/setgid bits.  Of course most potential 
> cases of triggering this issue with Unix permissions are extremely contrived 
> and wouldn't be a likely attack scenario.  The best example I can think of 
> with Unix permissions is access to sound devices.  If a system is configured 
> to add the "audio" supplementary group to a user's session when they login at 
> the console then they can keep a detached process running to maintain access 
> to the audio devices (and anything else permitted to that group).
>   

Checkpoint/restart has traditionally been interesting in the
mainframe and supercomputer space. These environments have very
different security profiles from a user desktop. No one at the
[.......] National Supercomputer Centre cares if you can save
your rogue game as soon as you pick up the Amulet of Yendor and
restart it if you get killed on the way up. These environments
are concerned with leaking data between the groups that have
funded the facility, which is why they are very often customers
of advanced access control technologies. I don't know that I see
a really good security story for C/R in the desktop space, and
as Russell points out, there are plenty of opportunities to
exploit the feature. This is of course well outside the scope of
what goes on within an LSM, where the specific issues are more
or less contained.


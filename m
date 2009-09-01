From: Russell Coker <russell-YtRjSb8ePh30CCvOHzKKcA@public.gmane.org>
Subject: Re: [PATCH 2/5] cr: checkpoint the active LSM and
	=?iso-8859-1?q?add=09RESTART=5FKEEP=5FLSM?= flag
Date: Tue, 1 Sep 2009 22:29:30 +1000
Message-ID: <200909012229.48973.russell@coker.com.au>
References: <20090828210041.GA27878@us.ibm.com>
	<20090830134809.GA14699@hallyn.com>
	<4A9ACBD4.4020804@schaufler-ca.com>
Reply-To: russell-YtRjSb8ePh30CCvOHzKKcA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A9ACBD4.4020804-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 31 Aug 2009, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org> wrote:
> I seem to be having some trouble presenting my point. It's not about
> the passwords. It's not about the firewall configuration. It's not
> even really about the SELinux policy. It's about the total security
> configuration of the system. This is a problem with checkpoint/restart
> in general and there isn't much we can do about reassigning user id
> and other bad things that can happen.
>
> If the admin decides that an action is acceptable because the SELinux
> policy prevents some other action it had better be the case that a
> process was never allowed to perform that "other action". If you allow
> restart across policy changes you can't be sure that the process has
> not performed such an "other action". Processes are not stateless.

Of course we potentially have the same issue when changing a boolean, and when 
loading a new policy on a running system.  In a realistic scenario, if you 
make a change that allows a process context to write to a public data store 
while at the same time denying read access to secret data then you also need 
to purge the contents of any files that the process may open for read/write.

Similar problems can also occur using Unix permissions and certain 
combinations of chmod with setuid/setgid bits.  Of course most potential 
cases of triggering this issue with Unix permissions are extremely contrived 
and wouldn't be a likely attack scenario.  The best example I can think of 
with Unix permissions is access to sound devices.  If a system is configured 
to add the "audio" supplementary group to a user's session when they login at 
the console then they can keep a detached process running to maintain access 
to the audio devices (and anything else permitted to that group).


PS  Do we really need so many on the CC list?  I removed a few entries of 
people who are on the SE Linux list.

-- 
russell-YtRjSb8ePh30CCvOHzKKcA@public.gmane.org
http://etbe.coker.com.au/          My Main Blog
http://doc.coker.com.au/           My Documents Blog

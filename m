From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [0/10] User namespaces: introduction
Date: Fri, 22 Aug 2008 14:45:13 -0500
Message-ID: <20080822194513.GA10262@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Eric,

so here is a start to a userns patchset trying to follow your ideas
about how to have user namespaces and filesystems interact.  Ignore
the bookkeeping crap or you'll pull your hair out.  Lots of stuff
remains unimplemented - i.e. chown (setattr) and proper handling of
capabilities.  But you can do some fun things with this patchset.
I.e.

	(log in as root)
	setcap cap_sys_admin=ep ns_exec
	setcap cap_sys_admin=ep usernsmount
	ns_exec -U /bin/sh
	ls /root (fails)
	ls / (succeeds)
	(log in as hallyn)
	ns_exec -U /bin/sh
	id
		(uid=0, gid=0)
	ls (fails, can't descend /home/hallyn)
	usernsmount / nsid=4
	ls (succeeds)
	touch ab
	ls -l ab
		(ab is owned by root)
	exit
	(we're logged in as hallyn in the init_user_ns again)
	ls -l ab
		(ab is owned by hallyn)

The only supported fs is ext3.  Only a few operations are supported.
So if, above, when we are hallyn in the init_user_ns but root in
the child user ns,
	when we create a file, it is properly handled, so
		inode->i_uid=500, but an xattr (nsid=4,uid=0) is added
	when we chown the file to root, it is not properly handled,
		so inode->i_uid = 0
it's just a matter of hooking all the places at this point.

Capabilities remain a problem.  Right now I think capabilities will
need to be split up into system-wide caps, and container-safe caps.
So CAP_NET_ADMIN, CAP_NET_RAW, CAP_DAC_OVERRIDE, those are container-safe.
CAP_REBOOT may become container-safe one day, but for now is very
much system-wide.

So if I'm uid 500 on the host and create a user namespace where I'm
uid=0, I should be able to acquire container-safe caps (perhaps
contingent on whether I unshared all other namespaces), but not
system-wide ones.  Or, whether I can acquire them would depend
on whether the suid bit was set in a user_ns or not.  sigh.

thanks,
-serge

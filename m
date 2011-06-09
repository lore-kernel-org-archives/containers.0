From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: user namespace testcases
Date: Thu, 9 Jun 2011 12:09:05 -0500
Message-ID: <20110609170905.GA29423@mail.hallyn.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey all,

sometime in the next two months I intend to write a set of testcases for
LTP for user namespaces.  Here is what I briefly jotted down for testcases
I intend to write.  If anyone else is interested in writing some, by all
means please feel free :)  This is a subtle feature and I feel it needs
to be methodically tested to make sure we're not breaking anything, and
that nothing gets broken later.

====

All start as root.

hostname
	1. sethostname(); should succeed
	2. setuid(500); sethostname: should fail
	3. clone(CLONE_NEWUTS); sethostname: should succeed
	4. clone(CLONE_NEWUTS|CLONE_NEWUSER); sethostname: should pass
	5. clone(CLONE_NEWUSER); sethostname: should fail
	6. setuid(500); clone(USER|UTS); sethostname; should pass
	Note that 6 requires keeping CAP_SETUID etc across setuid.

kill
	1.
	p1=fork; kill p1; should pass
	2.
	p1=fork and does setuid(500); should pass
	3.
	p1=fork; p2=fork; p1 does setuid(500); p1 kills p2; should fail
	4.
	p1=clone(NEWUSER); p2=fork; p1 kills p2; should fail
	5.
	p1=fork; p2=clone(NEWUSER); p1 kills p2; should pass
	6.
	p1 does setuid(500) then does clone(NEWUSER); p2 = fork; p1 kills p2.
	should fail
	7.
	p1 does setuid(500); p2 does setuid(500); p2 does clone(NEWUSER);
	p1 kills p2; should pass.

ptrace
	1. 
	p1=fork; p2=fork; pass p2.pid to p1
	p2: sleep(500);
	p1: setuid(500); ret = ptrace(p2); pass ret to parent
	should fail
	2.
	same as (1) without setuid; should succeed
	3. same as (1) but p2 also does setuid(500): should succeed
	4. same as (1), p1 created with clone(CLONE_NEWPID); should fail
	5. same as (1), p2 created with clone(CLONE_NEWPID); should pass
	6. same as (1), p1 and p2 setuid(500), and p2 created with CLONE_NEWPID;
	should pass
	7. same as (1), p1 setuid(500), p2 setuid(501), p2 created with
	CLONE_NEWPID; should fail
	Note that 6 and 7 require keeping CAP_SETUID etc across setuid.

reboot
	clone(CLONE_NEWUSER); reboot: should fail

===

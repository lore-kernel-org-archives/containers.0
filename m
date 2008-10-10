From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Keys and namespaces
Date: Fri, 10 Oct 2008 11:46:49 -0500
Message-ID: <20081010164649.GA24314@us.ibm.com>
References: <20081010011917.GA8046@us.ibm.com> <414.1223643503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <414.1223643503-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> 
> On the subject of namespaces: I still need to look at providing a key ID and
> keyring name namespace.
> 
> Is it worth me just using the user_namespace?  A number of parameters are
> per-UID (such as the key quotas), so it might very well make sense to do that.

I think it is.  The semantics will be interesting though.

> That way, user_namespace could actually be a credentials namespace.
> 
> If that is the case, CLONE_NEWUSER should also set up (clone?) the keys and
> keyrings attached to the parent.  This possibly needs to be done anyway as the
> keys have UID and GID references that may be invalid in the new namespace.
> 
> How do the UIDs and GIDs in different namespaces map, anyway?

Here is how we want it to work.  I will refer to the initial user
namespace as 0, and (500,0) will refer to uid 500 in the initial user
namespace.  If (500,0) creates a new user namespace and that user
namespace is 1, then the cloned task will be owned by uid (0,1).  The
creator of userns 1 is (500,0).

The cloned task, being root, will be able to exercise capabilities over
objects in its own namespace, but not, of course, over objects outside
its own namespace.  So let's say it clones a task which does
setuid(501).  Now the task owned by (0,1) can kill the task owned by
(501,1).  But it can't kill tasks in user_ns 0, even those owned by
(500,0), its creator.

> Furthermore, some keys may actually represent foreign user details; perhaps
> NTFS or CIFS user IDs for example.  Should those be discarded on CLONE_NEWUSER?

The intent is to implement roughly the following for file accesses:

	* If (501,1) creates a file in the above scenario, then it is
		owned by both (501,1) and (500,0), just as the task
		was.
	* File access may be granted at any level in the userns
		hierarchy, so (500,0) may access the above file.
		If (0,0) executs a setuid-(0,1) file, it will
		do so as a setuid(500,0) file.
	* Cross-userns access defaults to user-other.  So (0,1)
		will receive the 'other' permissions to any
		files owned by (0,0) which it happens to be able
		to get to.

I've taken a stab at the file accesses part, but will be starting
over from scratch after I try to address the capabilities part.
A great deal of discussion, mainly with Subject including 'user
namespaces' or user_ns, is in the containers mailing list archive.

So now the question is how should we treat keys :)

I'm actually confused about the current (in next-creds) approach.
The user_struct has uid_keyring and session_keyring.  But then
struct cred has its own 4 fields under CONFIG_KEYS - what are they?

Semantically, I think it makes sense at clone(CLONE_NEWUSER) to
give the new root user_struct in the new user_ns a copy of the
userns->creator's keychains.  Then that task can decide whether
to clear out the keychains or not.  This way the user can start
a container in his ecryptfs partition, and, if he wants to,
unlink the keys out before starting a user shell in his container,
for instance (not that that really makes sense).

Does that make sense?  (I imagine it'll have to be more complicated than
that :)

-serge

From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Containers don't handle keys, but should they?
Date: Fri, 14 Mar 2008 09:54:47 -0500
Message-ID: <20080314145447.GG9741@sergelap.austin.ibm.com>
References: <7519.1205494679@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7519.1205494679-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> 
> Am I right in thinking that a UID in one container is not necessarily
> equivalent to the numerically equivalent UID in another container?
> 
> If that's the case then the key management code will need changing as it
> assumes all keys belonging to one numeric UID eat out of the same quota and
> the numeric UIDs are used in security checks.
> 
> Furthermore, processes in one container can access keys created by a process
> in another container by ID.  Is this desirable or not?
> 
> David

Yes, the confusion comes from using the word 'container' which doesn't
really exist.  The user namespaces (CLONE_NEWUSER) are what provide
separate of uids.  We want uid 5 in one user namespace to have
completely separate set of keys from uid 5 in another user namespace.

This isn't yet a crucial thing to get right as the user namespaces are
only partially implemented, but it's certainly a good thing to be looking
at and fix when convenient to do so.  It looks like maybe just adding
a struct user_namespace * to a struct key should suffice.

-serge

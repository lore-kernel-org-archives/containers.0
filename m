From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Containers don't handle keys, but should they?
Date: Fri, 14 Mar 2008 11:17:11 -0500
Message-ID: <20080314161711.GA7166@sergelap.austin.ibm.com>
References: <20080314145447.GG9741@sergelap.austin.ibm.com>
	<7519.1205494679@redhat.com> <8853.1205509760@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8853.1205509760-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > It looks like maybe just adding a struct user_namespace * to a struct key
> > should suffice.
> 
> That's not quite sufficient.  The per-UID key_user structs also need to be
> differentiated.  Unfortunately, I can't just merge it into user_struct as I
> then end up with a reference loop user_struct -> uid_keyring -> user_struct.
> 
> Rooting the key_user trees in user_namespace will probably do the trick.
> 
> A couple of questions:
> 
>  (1) A process may inherit a session keyring over clone().  Should this be
>      discarded if CLONE_NEWUSER is set?  Or would I need to copy it?

Someone else may have stronger feelings about this.  Personally so long
as a container setup program has a way of discarding the keyring
manually I think that's fine.

>  (2) In a recent patch, I've given the root user its own quota limits.  Is UID
>      0 always the root user in any container?  Or would it make more sense
>      just to scrap the per-root quota limits?

Yeah uid 0 may not have a bunch of privileges, but it is still the root
user.

thanks,
-serge

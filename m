From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Tue, 25 Oct 2016 11:13:24 -0700
Message-ID: <1477419204.3079.60.camel@HansenPartnership.com>
References: <1477414605.3079.40.camel@HansenPartnership.com>
	<17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<18846.1477416621@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <18846.1477416621-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2016-10-25 at 18:30 +0100, David Howells wrote:
> James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
> 
> > > There's another possibility here - since user_namespaces are 
> > > hierarchical, does it make sense to let a process see keys that
> > > are 
> > > in an ancestral namespace?
> > 
> > I think that should be the decision of the owner.  If you're
> > creating a
> > userns to de-privilege the next user, likely you don't want this,
> > but
> > if you're creating a userns to enhance it, then you do.
> 
> Maybe the simplest is to put a 'stop here' flag on a user_namespace. 
>  Then when we look to see if a key is in the caller's namespace, we 
> go up the tree until we hit the flag.  If you don't find the key's ns 
> within the caller's permitted subtree, you don't get to see the key.

That sounds a bit nasty.  Even for nested user namespaces, what we
traditionally see is the interior uid and the exterior kuid; we don't
usually see the intermediary mappings unless you specifically traverse
the userns tree.

> > I think you want to behave exactly as the mount namespace does: on
> > initial clone, you get a fully cloned mount tree and then you 
> > customise it by unmounting pieces.
> 
> That adds quite a bit of complexity, given that:
> 
>  (1) we don't have an automatic updating view of a keyring as the 
> cloned mount tree does;

You're thinking of propagation?  The keyrings aren't currently
hierarchical in the same sense are they, so we really only need a top
level cloned, refcounted pointer.  Any change to the underlying keyring
could either COW the keyring or simply operate on the current one
(shared mount behaviour).  I'm betting the latter is far easier and if
you want the former, the orchestration system could simply copy all the
keys to a new keyring, release the old one and then rename the new one
to what the old one was, making it an orchestration problem to sort
out.

>  (2) there are quotas on the number of keys a user is permitted;

If this is counted per-id, then yes, mapping a range of ids with an
owning exterior non root user does allow you to escape the count ...
how important is it?  Could we not simply hand wave it away as yet
another consequence you have to think about when giving a user a range
of exterior ids (because if there are N, their key count could get up
to N * the limit).

>  (3) you may not have permission to 'dismount' part of the tree.

"root" in the userns should have.  I presume there's also some
capability we can give a non-root user.

> That said, it might be enough to just clone the *keyrings* and share
> the non-keyring keys.

Right ... do a refcounted clone structure and you can release the
keyring if the refcount goes to zero.

> David
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
> 

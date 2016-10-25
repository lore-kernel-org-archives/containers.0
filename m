From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Tue, 25 Oct 2016 09:49:13 -0700
Message-ID: <1477414153.3079.36.camel@HansenPartnership.com>
References: <17576.1477412418@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <17576.1477412418-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2016-10-25 at 17:20 +0100, David Howells wrote:
> I have some questions about user namespacing, with regard to making
> keyrings
> namespaced.  My current idea is to follow the following method:
> 
>  (1) A new key/keyring records the user_namespace active when it is
> created.
> 
>  (2) If a process's user_namespace doesn't match that recorded in a
> key then
>      it gets ENOKEY if it tries to refer to it or access it and can't
> see it
>      in /proc/keys.
> 
>  (3) A process's keyring subscriptions are cleared if CLONE_NEWUSER
> is passed
>      to clone() or to unshare() so that it doesn't retain a keyring
> it can't
>      access.
> 
>  (4) Each user_namespace has its own separate register of persistent
> keyrings
>      and KEYCTL_GET_PERSISTENT can only get from the register of the
> currently
>      caller's user_namespace.  This is already upstream
> 
> as this seems the simplest solution.  I don't want to add a new 
> CLONE_xxx flag as there isn't exactly a whole lot of room left.

OK, so the specific problem with this is that it fits perfectly the
container orchestration system use case but pretty much fails for any
non-orchestration use case.

For me it would fail in the architecture emulation use case: I actually
want an administerable container running as me, which means I use a
user_ns to escalate my privilege over the constrained system.  However,
doing this in your world would now divorce me from any keyring I had
access to, which isn't what I want.

Why not make it the job of the orchestration system to drop keyrings?
So by default CLONE_NEWUSER subscribes to the same keyrings the owning
user does?  That would mean it's configurable and you can add an extra
KEYCTL_ to give fine grained access, so subscriptions can be dropped
before the container is populated by its eventual end user, but the
default case is likely what someone using creation of a user_ns to
elevate their privilege wants.

James

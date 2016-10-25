From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Tue, 25 Oct 2016 11:05:08 -0700
Message-ID: <1477418708.3079.52.camel__44011.9612766013$1477418733$gmane$org@HansenPartnership.com>
References: <17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<1477414605.3079.40.camel@HansenPartnership.com>
	<20161025170602.GB24481@laptop.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161025170602.GB24481-GiL72Q0nGm9Crx9znvW9yA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2016-10-25 at 19:06 +0200, Jann Horn wrote:
> On Tue, Oct 25, 2016 at 09:56:45AM -0700, James Bottomley wrote:
> > On Tue, 2016-10-25 at 17:53 +0100, David Howells wrote:
> > > David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > 
> > > >  (2) If a process's user_namespace doesn't match that recorded
> > > > in a
> > > > key then
> > > >      it gets ENOKEY if it tries to refer to it or access it and
> > > > can't see it
> > > >      in /proc/keys.
> > > 
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
> > 
> > I think you want to behave exactly as the mount namespace does: on
> > initial clone, you get a fully cloned mount tree and then you
> > customise
> > it by unmounting pieces.
> 
> The issue with keys is that their interface is pretty broken when 
> exposed to user namespaces with different UID mappings, and this also 
> causes security issues where you can get access to other users' 
> keyrings and stuff like that. The proposed fix works around that 
> brokenness by simply never exposing keys to other namespaces.

Define how ... we can fix the keyring interface if it's hugely
problematic.

If you're simply thinking that it's a uid range mapping leak, then the
way I think of this is the same way the shadow utils do: the owning
user owns the exterior range of ids.  This seems to be the assumption
the unprivileged container systems are working on as well, so it
doesn't matter that there's a theoretical uid leak to the exterior
mapped ids.

> Your suggestion would probably be more flexible, but it'll require 
> some more, moderately ugly kernel code where various keyname prefixes 
> are special-cased so that names with these prefixes are dynamically
> translated into strings containing the KUID or so.

Can we not simply do it like mnt?  have a refcounted pointer structure
(struct mnt in its case) that points to a keyring.  This would
represent the subscription.  Once you detach it, you wouldn't be able
to recover it again.  So a user namespace wouldn't really be part of
the keyring prefix namespace.

James

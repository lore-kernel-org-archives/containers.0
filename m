From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Wed, 12 Jul 2017 19:43:44 -0500
Message-ID: <20170713004344.GA23272__28385.6181930334$1499906633$gmane$org@mail.hallyn.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87mv89iy7q.fsf@xmission.com>
	<20170712170346.GA17974@mail.hallyn.com>
	<877ezdgsey.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877ezdgsey.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> Stefan Berger <"Stefan Bergerstefanb"@linux.vnet.ibm.com> writes:
> >> > Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> >> > Signed-off-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> >> > Reviewed-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> >> 
> >> It doesn't look like this is coming through Serge so I don't see how
> >> the Signed-off-by tag is legtimate.
> >
> > This is mostly explained by the fact that there have been a *lot* of
> > changes, many of them discussed in private emails.
> >
> >> >From the replies to this it doesn't look like Serge has reviewed this
> >> version either.
> >> 
> >> I am disappointed that all of my concerns about technical feasibility
> >> remain unaddressed.
> >
> > Can you re-state those, or give a link to them?
> 
> Well I only posted about one substantive comment on the last round
> so it should be easy to find that said.

Ok so you are likely referring to http://lkml.org/lkml/2017/6/23/551 ,
thanks.  I had actually read that differently when you sent it, and
thought it was more to do with the suggestion of putting the nsid
tags in the middle of the xattr name versus putting it on the end.
As far as that is concerned, note that no other tags besides uid=
are currently supported, and only security.capability is being
namespaced.

> The big question is how does this intereact with filesystems
> xattr implementations?
> 
> There is the potential that we create many more security xattrs this
> way.  How does that scale?  With more names etc.
> What happens if we have one xattr per uid for 1000+ uids?

Well, that's not the intent here.  The goal is *not* to make one fs image
that satisfies 200k possible uid mappings.  The goal is to reconcile the
support for an unprivileged user to set uid agnostic (within the
container) file capabilities with the uid namespace's design goals -
namely root in a container is privileged over the container but
completely unprivileged wrt the host.

This is in part why in my previous version I only allowed a single
namespaced fscap.  But I don't think that we have to enforce a
single fscap - I think it's fair to tell users "go ahead and shoot
yourself in the foot" performance-wise, if they insist on doing
this.

The goal of now putting the root kuid in the name is not to support
multiple containers, but to have common code supporting
security.capability and security.ima, and maybe a few more.

> How does this interact with filesystems optimization of xattr names?
> For some filesystems they optmize the xattr names, and don't store the
> entire thing.

This I have no idea on.  Stefan, have you looked at this?

> > I'd really like to get to a point where unprivileged containers can start
> > using filecaps - at this point if that means having an extra temporary
> > file format based on my earlier patchset while we hash this out, that
> > actually seems worthwhile.  But it would of course be ideal if we could
> > do the name based caps right in the first place.
> 
> This whole new version has set my review back to square one
> unfortunately.

Well it is a whole new approach and whole new patch, so of course that's
to be expected :(

-serge

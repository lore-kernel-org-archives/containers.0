From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] keys: play nicely with user namespaces
Date: Fri, 19 Dec 2008 08:37:26 -0600
Message-ID: <20081219143726.GA10939@us.ibm.com>
References: <20081218174613.GA13968@us.ibm.com>
	<20081217235536.GA932@us.ibm.com>
	<20081212141707.GB9571@us.ibm.com>
	<20081211232323.GA8343@us.ibm.com> <3507.1229086294@redhat.com>
	<25987.1229097458@redhat.com> <3547.1229607983@redhat.com>
	<7376.1229648192@redhat.com> <7658.1229653824@redhat.com>
	<10350.1229685462@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <10350.1229685462-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> 
> > So far the design is that user namespaces are disjoint with one specific
> > exception.
> > 
> > The user who creates the user namespace is expected to have god like powers
> > over all users in the created user namespace.
> 
> I see.
> 
> > When carefully implemented will allow a user namespace to be created with
> > normal user permissions and for the user that created user namespace to
> > manage the resources owned by users in that user namespace.
> 
> I'm not sure how to deal with this wrt keys.  There are two problems to
> consider:
> 
>  (1) Should a key with UID 500 from namespace A in Serge's example be visible
>      in namespace B?

Conceptually that'd be nice, but it seems unnecessary since (IIUC)
userspace in the child userns can always reload the key.  So then
we can leverage the intricate fs controls (where in fact a file may
be owned by (A,500) and (B,0) simultaneoushly, or by (A,500) with
no visibility by (B,0), while keeping the keys access controls simpler.

That's why I'm keeping them strictly separate in the current patchset.
If that turns out to be too simplistic, then we can always enable
cross-userns visibility later.

>      If such a key should show up in namespace B, should its UID be given as 0
>      to userspace?

That is the model we want for filesystem, but I'm really hoping we can
keep the keys model simpler.

>  (2) How is the quota controlled?  Do new keys made up under the domain of
>      namespace B go to namespace B UID 0's quota?  Or do they come out of
>      namespace A's UID 500 quota?

Ideally it would be both.  Since the namespaces are hierarchical, the
requirement of safe unprivileged user-namespace cloning should hold
in a child user-ns too, so at each level we want keys being counted
toward the quota of the acting (uid,userns) as well as that of each
(uidX,usernsX) up the creator chain.

-serge

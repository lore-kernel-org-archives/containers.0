From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH review 48/85] sunrpc: Update gss uid to security context
	mapping.
Date: Wed, 13 Feb 2013 16:24:15 -0500
Message-ID: <20130213212415.GP14195@fieldses.org>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-48-git-send-email-ebiederm@xmission.com>
	<20130213203528.GN14195@fieldses.org> <87fw0zrk0e.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87fw0zrk0e.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Feb 13, 2013 at 01:17:37PM -0800, Eric W. Biederman wrote:
> "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:
> 
> > On Wed, Feb 13, 2013 at 09:51:37AM -0800, Eric W. Biederman wrote:
> >> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> 
> >> - Use from_kuid when generating the on the wire uid values.
> >> - Use make_kuid when reading on the wire values.
> >> 
> >> In gss_encode_v0_msg, since the uid in gss_upcall_msg is now a kuid_t
> >> generate the necessary uid_t value on the stack copy it into
> >> gss_msg->databuf where it can safely live until the message is no
> >> longer needed.
> >
> > Apologies, I haven't been following the user namespace work.
> >
> > If I understand correctly, you're expecting the id's seen in nfs
> > protocol messages to be the same as the id's seen in the initial user
> > namespace.
> >
> > Why is that right, and not, say, the user namespace in which the mount
> > was originally performed?  (Just asking, I honestly haven't thought
> > about it before.)
> 
> Actually my expectation is the user namespace was originally performed
> in.  Currently nfs doesn't support being  mounted in anything other
> than the initial user namespace.
> 
> > Also:
> >
> >> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> >> index afbbcfb..a360067 100644
> >> --- a/net/sunrpc/auth_gss/auth_gss.c
> >> +++ b/net/sunrpc/auth_gss/auth_gss.c
> >> @@ -395,8 +395,11 @@ gss_upcall_callback(struct rpc_task *task)
> >>  
> >>  static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
> >>  {
> >> -	gss_msg->msg.data = &gss_msg->uid;
> >> -	gss_msg->msg.len = sizeof(gss_msg->uid);
> >> +	uid_t uid = from_kuid(&init_user_ns, gss_msg->uid);
> >> +	memcpy(gss_msg->databuf, &uid, sizeof(uid));
> >> +	gss_msg->msg.data = gss_msg->databuf;
> >> +	gss_msg->msg.len = sizeof(uid);
> >> +	BUG_ON(sizeof(uid) > UPCALL_BUF_LEN);
> >
> > This message is going to gssd, not to the server.  Should it be encoded
> > for whatever namespace gssd lives in?
> 
> Good basic question.  The immediate answer is that right now I only
> support these things living in user namespace the filesystem was
> mounted in, aka the initial user namespace.
> 
> There are a handful of things ioctls, and a quota call or two that I
> will translate into the callers user namespace.  For network filesystems
> and their specialized helpers it would be lossy and unnecessarily
> complex to support arbitrary pieces living in different user namespaces.
> Historically unix has had syncrhonized password databases to ensure even
> multiple machines effectively had the same user namespace.
> 
> The really important step for me is to have the kernel using kuid_t and
> kgid_t throughout and only converting when talking outside of the kernel
> (disk, filesystem on disk data structures, network).
> 
> With that step I can enable user namespaces and the various filesystems.
> And even if the filesystem itself is restricted to just one user
> namespace, the users who read and write files on that filesystem won't
> be.
> 
> A next step for the filesystems where this is interesting is to support
> a user who is not the global root mounting the filesystem and having the
> filesystem speak in ids in the user namespace that the filesystem was
> mounted in.  That takes a little bit of connecting the dots of which
> user namespace goes where, and it takes a little bit of confidence that
> the kernel won't fall over if an evil server sends us deliberately bad
> protocol messages.  I suspect at some point someone will want to figure
> all of that out for nfs, certainly there has been work to figure that
> out for network namespaces.
> 
> For now though I am happy to have kuid_t and kgid_t pushed down
> everywhere they should be.

OK, makes sense, thanks for the explanation.--b.

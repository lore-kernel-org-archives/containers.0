From: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH RFC 10/12] userns: Convert xfs to use kuid/kgid/kprojid
	where appropriate
Date: Wed, 21 Nov 2012 11:52:47 -0800
Message-ID: <20121121195246.GN2822__49484.3108732768$1353528986$gmane$org@localhost>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
	<1353415420-5457-10-git-send-email-ebiederm@xmission.com>
	<20121120235524.GK2591@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121120235524.GK2591@dastard>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: Alex Elder <elder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Myers <bpm-sJ/iWh9BUns@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 21, 2012 at 10:55:24AM +1100, Dave Chinner wrote:
> > diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
> > index 2778258..3656b88 100644
> > --- a/fs/xfs/xfs_inode.c
> > +++ b/fs/xfs/xfs_inode.c
> > @@ -570,11 +570,12 @@ xfs_dinode_from_disk(
> >  	to->di_version = from ->di_version;
> >  	to->di_format = from->di_format;
> >  	to->di_onlink = be16_to_cpu(from->di_onlink);
> > -	to->di_uid = be32_to_cpu(from->di_uid);
> > -	to->di_gid = be32_to_cpu(from->di_gid);
> > +	to->di_uid = make_kuid(&init_user_ns, be32_to_cpu(from->di_uid));
> > +	to->di_gid = make_kgid(&init_user_ns, be32_to_cpu(from->di_gid));
> 
> You can't do this, because the incore inode structure is written
> directly to the log. This is effectively an on-disk format change.

	Yeah, I don't get this either.  Over in ocfs2, you do the
correct thing, translating at the boundary from ocfs2_dinode to struct
inode.

Joel

-- 

"I always thought the hardest questions were those I could not answer.
 Now I know they are the ones I can never ask."
			- Charlie Watkins

			http://www.jlbec.org/
			jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org

From: Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH RFC 09/12] userns: Convert ocfs2 to use kuid and kgid
	where appropriate
Date: Wed, 21 Nov 2012 11:51:15 -0800
Message-ID: <20121121195114.GM2822__17076.7284733758$1353528980$gmane$org@localhost>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
	<1353415420-5457-9-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1353415420-5457-9-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 20, 2012 at 04:43:37AM -0800, Eric W. Biederman wrote:
> --- a/fs/ocfs2/file.c
> +++ b/fs/ocfs2/file.c
> @@ -1116,7 +1116,8 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
>  			    (unsigned long long)OCFS2_I(inode)->ip_blkno,
>  			    dentry->d_name.len, dentry->d_name.name,
>  			    attr->ia_valid, attr->ia_mode,
> -			    attr->ia_uid, attr->ia_gid);
> +			    from_kuid(&init_user_ns, attr->ia_uid),
> +			    from_kgid(&init_user_ns, attr->ia_gid));

Dear Eric,
	I have a similar question about init_user_ns to Dave.  As far as
I can tell, using init_user_ns here means we'll never get translations
based on the current process namespace.  It just so happens that
include/linux/user_namespace.h doesn't allow new namespaces yet, but I
can't see why we would propagate that knowledge elsewhere.
	Is there some magic about when init_user_ns should be used
regardless?

Joel

-- 

 Brain: I shall pollute the water supply with this DNAdefibuliser,
        turning everyone into mindless slaves.
 Pinky: What about the people who drink bottled water?
 Brain: Pinky, people who pay 5 dollars for a bottle of water are
        already mindless slaves.

			http://www.jlbec.org/
			jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org

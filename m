From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH RFC 0/12] Final userns conversions
Date: Wed, 21 Nov 2012 11:09:52 +1100
Message-ID: <20121121000952.GL2591@dastard>
References: <87pq38wimv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87pq38wimv.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 20, 2012 at 04:42:16AM -0800, Eric W. Biederman wrote:
> 
> This patchset contain the basic user namespace changes for filesystems
> that have needed nontrivial work.  Along with the 2 patches that depend
> on these changes.
> 
> I belive these patches to be correct for allowing the remaining
> filesystems to work in the presence of user namespaces.  At the same
> time I would like to give all of these much deeper scrutiny, just
> because there is so much going on.  Unfortunately these patches
> individually are not obviously correct.
> 
> Since I won't have much time until after Thanksgiving and because the
> merge window is looming I figure I will put these changes out there and
> let people see I am looking at these changes, and see if anyone happens
> to spot anything.

The XFS stuff is non-trivial, causes on-disk format changes and
likely breaks xfsdump/xfsrestore, so the XFS patch is a no-go until
that is sorted out.

Given the short time until the merge window and that the XFS patch
needs to be significantly revised, it's already too late for the XFS
changes to be considered for the 3.8 merge window.  Hence I'd
suggest that you are going to be targeting 3.9 for the XFS changes.

> If I can figure out how to responsibly get these changes into linux-next
> I want to get these changes into linux-next so that user namespace bugs
> show up in allyesconfig builds.

The XFS changes definitely need to be staged through the XFS tree
given the complexity of the changes, the amount of validation that
is required. Also, it is likely that there are significant conflicts
against changes already staged for 3.8, so getting it upstream
through the XFS tree is the only option that I'd consider
acceptible...

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org

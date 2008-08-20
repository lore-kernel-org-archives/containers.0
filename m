From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Wed, 20 Aug 2008 15:11:54 -0700
Message-ID: <1219270314.8960.74.camel__41225.9432524026$1219270450$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<200808090013.41999.arnd@arndb.de> <20080811152201.GB25930@us.ibm.com>
	<200808111853.13854.arnd@arndb.de> <1218484114.5598.43.camel@nimitz>
	<48A0CD86.6030704@goop.org> <1218553091.5598.76.camel@nimitz>
	<48A1BB39.3090108@goop.org> <1218559619.5598.97.camel@nimitz>
	<48AC929C.9030901@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48AC929C.9030901-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Daniel Lezcano <daniel.lezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2008-08-20 at 17:54 -0400, Oren Laadan wrote:
> > Me, personally, I think I'd probably "re-link" the thing, mark it as
> > such, ship it across like a normal file, then unlink it after the
> > restore.  I don't know what we'd choose when actually implementing
> it.  
> 
> Re-linking works well when the file system supports that - some do not
> allow this, in which case you need to silently rename instead of really
> un-linking (even with NFS), or copy the entire contents.

Yeah, it will certainly be fs-dependent.

This might be a good application for splice.

	open("/tmp/linked-newfile", O_RDONLY, perms);
	splice(unlinked_fd, NULL, new_fd, NULL, MAX_INT, SPLICE_F_MOVE);

I'm not sure if it can re-use the blocks on the fs for this, but it
probably doesn't matter.  

-- Dave

From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 4/8] file c/r: expose functions to query fs support
Date: Fri, 27 Feb 2009 13:32:54 -0800
Message-ID: <1235770374.26788.395.camel__43300.1651465476$1235770551$gmane$org@nimitz>
References: <20090227203425.F3B51176@kernel>
	<20090227203429.6963AFC4@kernel> <20090227211408.GB19872@us.ibm.com>
	<1235769880.26788.394.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1235769880.26788.394.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-02-27 at 13:24 -0800, Dave Hansen wrote:
> On Fri, 2009-02-27 at 13:14 -0800, Sukadev Bhattiprolu wrote:
> > Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
> > | +int cr_file_supported(struct file *file)
> > | +{
> > | +   struct inode *inode = file->f_dentry->d_inode;
> > | +   struct file_system_type *fs_type = inode->i_sb->s_type;
> > | +
> > | +   if (fs_is_cr_able(fs_type))
> > | +           return 0;
> > 
> > Should this be if (!fs_is_cr_able(fs_type)) ?
> 
> Yes.  I did find and fix that at some point, but it appears I didn't
> manage to integrate it into what I sent out.

Yeah, I think I managed to accidentally dump the fix into the next patch
instead of this one.  I'll correct that in the next set.

-- Dave

From: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] devpts_get_tty() should validate inode
Date: Tue, 17 Nov 2009 19:44:50 -0800
Message-ID: <20091118034450.GB17349__10689.8148464554$1258516707$gmane$org@suse.de>
References: <20091118023541.GA14430@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091118023541.GA14430-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 17, 2009 at 06:35:43PM -0800, Sukadev Bhattiprolu wrote:
> 
> devpts_get_tty() assumes that the inode passed in is associated with a valid
> pty.  But if the only reference to the pty is via a bind-mount, the inode
> passed to devpts_get_tty() while valid, would refer to a pty that no longer
> exists.
> 
> With a lot of debug effort, Grzegorz Nosek developed a small program (see
> below) to reproduce a crash on recent kernels. This crash is a regression
> introduced by the commit:
> 
> 	commit 527b3e4773628b30d03323a2cb5fb0d84441990f
> 	Author: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 	Date:   Mon Oct 13 10:43:08 2008 +0100
> 
> To fix, ensure that the dentry associated with the inode has not yet been
> deleted/unhashed by devpts_pty_kill().
> 
> See also:
> https://lists.linux-foundation.org/pipermail/containers/2009-July/019273.html 

Good debugging, I'll queue this up.

greg k-h

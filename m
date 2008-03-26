From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7]: Determine pts_ns from a pty's inode.
Date: Tue, 25 Mar 2008 21:50:38 -0500
Message-ID: <20080326025038.GA24538@sergelap.austin.ibm.com>
References: <20080325035904.GB27451@us.ibm.com>
	<20080325042541.GE27864@us.ibm.com>
	<20080325151705.GE9561@sergelap.austin.ibm.com>
	<20080325211406.GA5817@sergelap.austin.ibm.com>
	<20080326020328.GA11747@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080326020328.GA11747-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> | > Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> | > > 
> | > > From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> | > > Subject: [PATCH 5/7]: Determine pts_ns from a pty's inode.
> | > > 
> | > > The devpts interfaces currently operate on a specific pts namespace
> | > > which they get from the 'current' task.
> | > > 
> | > > With implementation of containers and cloning of PTS namespaces, we want
> | > > to be able to access PTYs in a child-pts-ns from a parent-pts-ns. For
> | > > instance we could bind-mount and pivot-root the child container on
> | > > '/vserver/vserver1' and then access the "pts/0" of 'vserver1' using 
> | > > 
> | > > 	$ echo foo > /vserver/vserver1/dev/pts/0
> | > > 	
> | > > The task doing the above 'echo' could be in parent-pts-ns. So we find
> | > > the 'pts-ns' of the above file from the inode representing the above
> | > > file rather than from the 'current' task.
> | > > 
> | > > Note that we need to find and hold a reference to the pts_ns to prevent
> | > > the pts_ns from being freed while it is being accessed from 'outside'.
> | > > 
> | > > This patch implements, 'pts_ns_from_inode()' which returns the pts_ns
> | > > using 'inode->i_sb->s_fs_info'.
> | > > 
> | > > Since, the 'inode' information is not visible inside devpts code itself,
> | > > this patch modifies the tty driver code to determine the pts_ns and passes
> | > > it into devpts.
> | > > 
> | > > TODO:
> | > > 	What is the expected behavior when '/dev/tty' or '/dev/ptmx' are
> | > > 	accessed from parent-pts-ns. i.e:
> | > > 
> | > > 		$ echo "foobar" > /vserver/vserver1/dev/tty)
> | > > 		
> | > > 	This patch currently ignores the '/vserver/vserver1' part (that
> | > 
> | > The way this is phrased it almost sounds like you're considering using
> | > the pathnames to figure out the ptsns to use :).
> | > 
> | > It's not clear to me what is the sane thing to do.
> | > 
> | > what you're doing here - have /dev/ptmx and /dev/tty always use
> | > current->'s ptsns - isn't ideal.
> | > 
> | > It would be nicer to not have a 'devpts ns', and instead have a
> | > full device namespace.  However, then it still isn't clear how to tie
> | > /vs/vs1/dev/ptmx to vs1's device namespace, since there is no device
> | > fs to which to tie the devns.
> | > 
> | > We could tie the devns to a device inode on mknod, using the devns of
> | > the creating task.  Then when starting up vs1, you just have to always
> | > let vs1 create /dev/ptmx and /dev/tty.  I can't think of anything
> | > better offhand.
> | > 
> | > Other ideas?
> | 
> | I suppose you could just create /dev/pts/ptmx and /dev/pts/tty.
> | Recommend that in containers /dev/ptmx and /dev/tty be symlinks
> | into /dev/pts.  Applications don't need to change.  If
> | ptmx_open() sees that inode->i_sb is a devptsfs, it gets the
> | namespace from the sb.  If not, then it was a device in /dev
> | and it gets the nmespace from current.
> 
> But we would still depend on user-space remounting /dev/pts after
> the clone right ? Until they do that we would access the parent
> container's /dev/pts/ptmx ?

Yes.  Which is the right thing to do imo.

-serge

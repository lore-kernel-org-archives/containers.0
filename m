From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/6] c/r: [pty 2/2] support for pseudo terminals
Date: Fri, 4 Sep 2009 11:21:58 -0500
Message-ID: <20090904162158.GA17315@us.ibm.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
	<1252074054-22241-4-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1252074054-22241-4-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> This patch adds support for checkpoint and restart of pseudo terminals
> (PTYs). Since PTYs are shared (pointed to by file, and signal), they
> are managed via objhash.
> 
> PTYs are master/slave pairs; The code arranges for the master to
> always be checkpointed first, followed by the slave. This is important
> since during restart both ends are created when restoring the master.
> 
> In this patch only UNIX98 style PTYs are supported.
> 
> Currently only PTYs that are referenced by open files are handled.
> Thus PTYs checkpoint starts with a file in tty_file_checkpoint(). It
> will first checkpoint the master and slave PTYs via tty_checkpoint(),
> and then complete the saving of the file descriptor. This means that
> in the image file, the order of objects is: master-tty, slave-tty,
> file-desc.
> 
> During restart, to restore the master side, we open the /dev/ptmx
> device and get a file handle. But at this point we don't know the
> designated objref for this file, because the file is due later on in
> the image stream. On the other hand, we can't just fput() the file
> because it will close the PTY too.
> 
> Instead, when we checkpoint the master PTY, we _reserve_ an objref
> for the file (which won't be further used in checkpoint). Then at
> restart, use it to insert the file to objhash.
> 
> TODO:
> 
> * Better sanitize input from checkpoint image on restore
> * Check the locking when saving/restoring tty_struct state
> * Echo position/buffer isn't saved (is it needed ?)
> * Handle multiple devpts mounts (namespaces)
> * Paths of ptmx and slaves are hard coded (/dev/ptmx, /dev/pts/...)
> 
> Changelog[v1]:
>   - Adjust include/asm/checkpoint_hdr.h for s390 architecture
>   - Add NCC to kernel constants header (ckpt_hdr_const)
>   - [Serge Hallyn] fix calculation of canon_datalen
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

First three patches can get

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

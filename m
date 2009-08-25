From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3] c/r: [pty 1/2] allow allocation of desired	pty
	slave
Date: Tue, 25 Aug 2009 14:28:12 -0400
Message-ID: <4A942D3C.8030504@librato.com>
References: <1250642549-23656-1-git-send-email-orenl@librato.com>
	<1250642549-23656-3-git-send-email-orenl@librato.com>
	<20090825145817.GA22351@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090825145817.GA22351-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>> During restart, we need to allocate pty slaves with the same
>> identifiers as recorded during checkpoint. Modify the allocation code
>> to allow an in-kernel caller to request a specific slave identifier.
>>
>> For this, add a new field to task_struct - 'required_id'. It will
>> hold the desired identifier when restoring a (master) pty.
> 
> This is really unfortunate.

:(

> 
> I assume you left the rather generic name 'required_id' because
> you intend to use it for other calls as well?  Which is even
> more unfortunate...

:'(

> 
> I know I'm generally the one who pushes for re-using existing
> helpers as much as possible, both to avoid missing existing
> security checks, and to prevent future code changes which forget
> to update the c/r code.
> 
> But in this case I don't think re-using fopen to ask the kernel
> to create a new device with more info than fopen usually gets is
> right.  Unfortunately, actually coming up with 'the right way' is
> escaping me at the moment :)
> 
> Though... then again...  your code is hardcoded for devpts and
> opening /dev/ptmx anyway, so surely we can create a new helper
> which takes a devpts_ns and index and returns the new devpts
> tty_struct without using the current->required_id?

The problem is that the way pty works: the index allocation takes
place inside ptmx_open(). As it is, I can't find of a way to
directly transfer a piece of data to it, because all we do is
call filp_open().

For this, we need add new functionality for pty code to

a) Allocate a master PTY without the corresponding file; this
function will be called from ptmx_open() and from restart code,
and will accept the "desired index" variable.

b) Attach an existing (master) PTY to a file pointer. This
will also be called from ptmx_open() and from restart code.

and

c) For restart only, manually do the work of filp_open() to
create a file, dentry, inode etc. This is what I really wanted
to avoid.

> 
> Then, if we ever want to support a tty type other than unix98,
> maybe we can more generally split up more like:

Other tty types have index that is indicated by the device minor
number (e.g. old style PTYs) or no index considerations :)

Oren.

> 
> 	1. add 'struct tty_struct *make_tty(struct tty_driver *driver,
> 			void *data) to tty_operations.  It is
> 			undefined for all but devpts.
> 	2. for devpts, the void *data includes an int devpts_ns_id
> 			and index
> 	3. the container-level checkpoint stores a relation between
> 		pathnames and devpts_ns_id.  devpts_ns_id is valid
> 		only for one checkpoint image.  The pathname is
> 		where that devpts_ns is mounted.  If we ever start
> 		checkpointing and restoring fs mounts from kernel,
> 		then we can tweak this treatment.  For now it is
> 		assumed (and verified) that at restart, pathname is
> 		in fact where a devpts instance is mounted.
> 	4. the tty_struct itself is checkpointed and restored.  It
> 		is restored using make_tty() in tty_operations,
> 		and for devpts the void *data  is a struct storing
> 		the devpts_ns_id and index.
> 	5. when a struct file for a devpts is restored, the tty_struct
> 		will already have been re-created.  The  tty_struct's objref
> 		is stored in the file struct checkpoint data.
> 
> It requires more finagling of the file/inode/tty_struct relationship
> though...  But I don't see required_id being acceptable upstream.
> 
> Of course I've been wrong about such things before.
> 
> -serge

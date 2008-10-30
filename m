From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 13:40:25 -0700
Message-ID: <1225399225.12673.370.camel@nimitz>
References: <1225219047.12673.182.camel@nimitz>
	<4909FAA8.5000107@cs.columbia.edu> <1225395451.12673.348.camel@nimitz>
	<490A15F5.6010702@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <490A15F5.6010702-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-10-30 at 16:15 -0400, Oren Laadan wrote:
> Dave Hansen wrote:
> > This is a blob.  It's simply a blob exported in a filesystem.  Note that
> > it exports the same format as the 'big blob' with the same types.  Stick
> > a couple of cr_hdr* objects on to what we have in the filesystem, and we
> > get the same blob that we have now.
> > 
> > How would a tarball of this filesystem be any less of a blob than the
> > output from sys_checkpoint() is now?
> 
> It isn't a blob per se - it exposes the structure via the file system;
> tomorrow someone will write a program that relies on that structure, and
> the next time you wanna change something you open a can of worms.

This is an ABI that I'm proposing.  But, so is the blob from the
syscall.  Are you saying that people can't write programs that depend on
the structure of the data returned from the syscall?  

> How likely is this to happen if you used, for instance, a single file in
> your file system approach ?

Definite.  Just as people will write programs to access only parts of
the resultant sys_checkpoint() files.

> > If we were doing a configfs-style restart, the restarter would simply
> > restore those two files.  The act of doing open(O_CREAT) is the same
> > trigger as what you have now when a cr_hdr of some type is encountered.
> 
> What you did not address in your response, is that the thing with shared
> resources is that they appear more than once. In your terminology, they
> would show up in multiple places in the tree. Then they would be saved
> multiple times ?

*References* will show up more than once.  But, filesystems handle
references today with symlinks or hard links.  We could either do that
or force userspace to do the duplicate and sharing detection itself.

You could get nice and creative here.  For instance, look at the link
count on a file.  If it is 1, write out the record for that resource
into the checkpoint file.  If it is >1, then write out a reference and
unlink the file.  

-- Dave

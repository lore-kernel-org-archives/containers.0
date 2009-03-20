From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 20/23] Restore anonymous- and file-mapped-
	shared memory
Date: Fri, 20 Mar 2009 14:42:45 -0700
Message-ID: <1237585365.8286.322.camel@nimitz>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
	<1237574868-3371-21-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237574868-3371-21-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-03-20 at 14:47 -0400, Oren Laadan wrote:
> 
> The bulk of the work is in cr_read_vma(), which has been refactored:
> the part that create the suitable 'struct file *' for the mapping is
> now larger and moved to a separate function. What's left is to read
> the VMA description, get the file pointer, create the mapping, and
> proceed to read the contents in.
> 
> Both anonymous shared VMAs that have been read earlier (as indicated
> by a look up to objhash) and file-mapped shared VMAs are skipped.
> Anonymous shared VMAs seen for the first time have their contents
> read in directly to the backing inode, as indexed by the page numbers
> (as opposed to virtual addresses).

This turns cr_write_vma() into a 120-line behemoth.  I'd really suggest
getting in there and trying to abstract things out a bit.  It is pretty
hard to follow as it stands.

-- Dave
